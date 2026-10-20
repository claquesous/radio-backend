# Finds songs similar to one or more seed songs along three independent facets:
#
#   sound     - Essentia sound embeddings, plus a small bonus for harmonically
#               compatible keys and mixable tempos
#   creators  - exact weighted overlap of credits (performer/producer/writer...)
#   genre_era - genre/style tag embeddings averaged with closeness in original
#               release year (Gaussian decay)
#
# Raw cosine similarities sit on very different scales per facet (most genre pairs
# score ~0.95, most sound pairs ~0.6), so sound and genre are rescaled with
# FacetCalibration before blending (0 for a typical pair, rising through the
# closest percentiles). Creator similarity is exact credit overlap, already 0 for
# "nobody shared", so it is used as is. Only the weights' ratios matter.
#
# Candidates come from an HNSW nearest-neighbor query per weighted facet, and every
# candidate is then rescored on all facets, so a song surfaced by sound is still
# credited for sharing a producer. A facet a candidate has no data for scores 0.
#
# With several seeds, each seed nominates candidates and every candidate is scored
# against every seed. The result is the mean, so a song has to suit all the seeds
# to rank well, not just one of them.
#
# An artist's own songs share every credit, genre and era with each other, so
# left alone they crowd out everything else. By default the seeds' artists are
# excluded (same_artist: true allows them) and each artist contributes at most
# per_artist songs.
class Recommender
  FACETS = %i[sound creators genre_era].freeze
  CANDIDATES_PER_FACET = 200
  ERA_SIGMA_YEARS = 5.0
  KEY_BONUS = 0.05
  TEMPO_BONUS = 0.05
  TEMPO_TOLERANCE = 0.06

  # Raw per-facet similarities, reported alongside the calibrated scores.
  SIMILARITIES = {
    sound: :sound_embedding,
    creators: :creator_embedding,
    genre: :genre_embedding
  }.freeze

  Result = Struct.new(:song, :score, :scores, :details, keyword_init: true)

  # seeds: a Song or an array of Songs.
  # stream: only recommend songs in this stream's chooser set.
  # excluding_stream: only recommend songs not yet in this stream's chooser set.
  # exclude_ids: song ids never to recommend (e.g. ones already shown).
  def self.similar(seeds, weights:, **options)
    new(seeds, weights:, **options).similar
  end

  def initialize(seeds, weights:, stream: nil, excluding_stream: nil, exclude_ids: [], limit: 25,
                 same_artist: false, per_artist: 1)
    @songs = Array(seeds)
    calibrations = FacetCalibration.all.index_by { |c| c.facet.to_sym }
    @seeds = @songs.filter_map do |song|
      seed = Seed.new(song, weights, calibrations)
      seed if seed.usable?
    end
    @stream = stream
    @excluding_stream = excluding_stream
    @exclude_ids = exclude_ids
    @limit = limit
    @same_artist = same_artist
    @per_artist = per_artist
  end

  def similar
    return [] if @seeds.empty?

    SongFeature.transaction do
      # Filtered HNSW scans (e.g. limited to a stream's choosers) otherwise stop
      # after ef_search rows and can return far fewer than requested.
      SongFeature.connection.execute("SET LOCAL hnsw.iterative_scan = relaxed_order")
      ids = @seeds.flat_map { |seed| seed.candidate_ids(scope) }.uniq
      ids.empty? ? [] : rank(combine(@seeds.map { |seed| seed.score(ids) }))
    end
  end

  class << self
    # Camelot wheel: same position (same key, or relative major/minor), or one
    # step around the circle of fifths in the same mode.
    def compatible_keys?(key_a, mode_a, key_b, mode_b)
      return false if [key_a, mode_a, key_b, mode_b].any?(&:nil?)
      distance = (camelot_position(key_a, mode_a) - camelot_position(key_b, mode_b)).abs
      distance = [distance, 12 - distance].min
      distance.zero? || (distance == 1 && mode_a == mode_b)
    end

    # Within tolerance directly, or at double/half time.
    def compatible_tempos?(bpm_a, bpm_b)
      return false unless bpm_a.to_f.positive? && bpm_b.to_f.positive?
      ratio = bpm_b.to_f / bpm_a
      [ratio, ratio * 2, ratio / 2].any? { |r| (r - 1).abs <= TEMPO_TOLERANCE }
    end

    private

      def camelot_position(key, mode)
        relative_major = mode == "minor" ? key + 3 : key
        (relative_major * 7) % 12
      end
  end

  private

    def scope
      base = SongFeature.where.not(song_id: @songs.map(&:id) + @exclude_ids.to_a)
      base = base.where(song_id: @stream.choosers.unscope(:order).select(:song_id)) if @stream
      base = base.where.not(song_id: @excluding_stream.choosers.unscope(:order).select(:song_id)) if @excluding_stream
      unless @same_artist
        base = base.where.not(song_id: Song.unscoped.where(artist_id: @songs.map(&:artist_id).uniq).select(:id))
      end
      base
    end

    # Averages each candidate over all seeds. A facet's score is averaged over the
    # seeds that weight it; the overall score over every seed.
    def combine(per_seed)
      per_seed.first.keys.map do |id|
        rows = per_seed.map { |scored| scored[id] }
        facets = rows.flat_map { |row| row.scores.keys }.uniq
        Scored.new(
          song_id: rows.first.song_id,
          artist_id: rows.first.artist_id,
          total: mean(rows.map(&:total)),
          scores: facets.index_with { |facet| mean(rows.filter_map { |row| row.scores[facet] }) },
          raw: rows.flat_map { |row| row.raw.compact.keys }.uniq
            .index_with { |name| mean(rows.filter_map { |row| row.raw[name] }) }
        )
      end
    end

    def mean(values)
      values.sum / values.size
    end

    def rank(scored)
      top = per_artist_cap(scored.select { |row| row.total.positive? }.sort_by { |row| -row.total })
        .first(@limit)
      songs = Song.unscoped.includes(:artist, :album, :song_feature).where(id: top.map(&:song_id)).index_by(&:id)
      top.map do |row|
        Result.new(song: songs[row.song_id], score: row.total.round(4),
                   scores: row.scores.transform_values { |s| s.round(4) },
                   details: row.raw.compact.transform_values { |s| s.round(4) })
      end
    end

    def per_artist_cap(rows)
      taken = Hash.new(0)
      rows.select { |row| (taken[row.artist_id] += 1) <= @per_artist }
    end

    Scored = Struct.new(:song_id, :artist_id, :total, :scores, :raw, keyword_init: true)

    # One seed song: its features, the weights it can use, and how it scores
    # candidates.
    class Seed
      def initialize(song, weights, calibrations)
        @song = song
        @feature = song.song_feature
        @calibrations = calibrations
        @weights = normalize(weights)
      end

      def usable?
        @feature.present? && @weights.any?
      end

      def candidate_ids(scope)
        ids = []
        ids += neighbor_ids(scope, :sound_embedding) if @weights.key?(:sound)
        ids += neighbor_ids(scope, :creator_embedding) if @weights.key?(:creators)
        if @weights.key?(:genre_era)
          ids += neighbor_ids(scope, :genre_embedding) if @feature.genre_embedding.present?
          ids += year_neighbor_ids(scope) if @feature.release_year.present?
        end
        ids
      end

      # Similarities are computed against the seed row in SQL, which works the same
      # for dense and sparse vectors and is NULL when either side has no data.
      # Returns { song_feature id => Scored }.
      def score(ids)
        seed = SongFeature.sanitize_sql_array([<<~SQL, @feature.id])
          CROSS JOIN (SELECT sound_embedding AS seed_sound, creator_embedding AS seed_creators,
                             genre_embedding AS seed_genre
                      FROM song_features WHERE id = ?) seed
        SQL
        SongFeature.where(id: ids).joins(:song).joins(seed)
          .select(:id, :song_id, :key, :mode, :bpm, :release_year, "songs.artist_id",
                  "1 - (sound_embedding <=> seed_sound) AS sound_similarity",
                  "1 - (creator_embedding <=> seed_creators) AS creators_similarity",
                  "1 - (genre_embedding <=> seed_genre) AS genre_similarity")
          .to_h do |candidate|
            raw = raw_similarities(candidate)
            scores = facet_scores(candidate, raw)
            [candidate.id, Scored.new(song_id: candidate.song_id, artist_id: candidate.artist_id, raw:, scores:,
                                      total: @weights.sum { |facet, weight| weight * scores[facet] })]
          end
      end

      private

        def normalize(weights)
          usable = weights.to_h.transform_keys(&:to_sym).slice(*FACETS)
            .transform_values(&:to_f)
            .select { |facet, weight| weight.positive? && target_present?(facet) }
          total = usable.values.sum
          usable.transform_values { |weight| weight / total }
        end

        def target_present?(facet)
          return false if @feature.nil?
          case facet
          when :sound then @feature.sound_embedding.present?
          when :creators then @feature.creator_embedding.present?
          when :genre_era then @feature.genre_embedding.present? || @feature.release_year.present?
          end
        end

        def neighbor_ids(scope, column)
          scope.nearest_neighbors(column, @feature.public_send(column), distance: "cosine")
            .limit(CANDIDATES_PER_FACET).pluck(:id)
        end

        def year_neighbor_ids(scope)
          scope.where.not(release_year: nil)
            .order(Arel.sql(SongFeature.sanitize_sql_array(["abs(release_year - ?)", @feature.release_year])))
            .limit(CANDIDATES_PER_FACET).pluck(:id)
        end

        def raw_similarities(candidate)
          SIMILARITIES.keys.to_h { |facet| [facet, candidate.attributes["#{facet}_similarity"]&.to_f] }
            .merge(era: era_similarity(candidate.release_year))
        end

        def facet_scores(candidate, raw)
          @weights.keys.index_with do |facet|
            case facet
            when :sound
              sound_score(candidate, raw[:sound])
            when :creators
              raw[:creators] ? raw[:creators].clamp(0.0, 1.0) : 0.0
            when :genre_era
              genre_era(raw)
            end
          end
        end

        # Key/tempo compatibility breaks ties between songs that already sound alike;
        # it never turns a below-typical pair into a match. The bonus shrinks with the
        # headroom left below 1, so near-identical matches stay ranked instead of all
        # capping at 1.
        def sound_score(candidate, similarity)
          return 0.0 unless similarity
          base = calibrated(:sound, similarity)
          base.positive? ? base + harmonic_bonus(candidate) * (1.0 - base) : 0.0
        end

        # The mean of whichever of genre and era the seed has data for.
        def genre_era(raw)
          parts = []
          parts << (raw[:genre] ? calibrated(:genre, raw[:genre]) : 0.0) if @feature.genre_embedding.present?
          parts << (raw[:era] || 0.0) if @feature.release_year.present?
          parts.sum / parts.size
        end

        def calibrated(facet, similarity)
          calibration = @calibrations[facet]
          calibration ? calibration.normalize(similarity) : similarity.clamp(0.0, 1.0)
        end

        def era_similarity(year)
          return nil if year.nil? || @feature.release_year.nil?
          Math.exp(-((year - @feature.release_year)**2) / (2 * ERA_SIGMA_YEARS**2))
        end

        def harmonic_bonus(candidate)
          bonus = 0.0
          bonus += KEY_BONUS if Recommender.compatible_keys?(@feature.key, @feature.mode, candidate.key, candidate.mode)
          bonus += TEMPO_BONUS if Recommender.compatible_tempos?(@feature.bpm, candidate.bpm)
          bonus
        end
    end
end
