# Runs one song through radio-analyzer (identify -> analyze -> enrich -> genre
# embedding) and stores what comes back in song_features, credits, song_tags,
# people and the songs/artists/albums external-id columns.
#
# Every step only runs when it still needs to, so a song can be passed through
# again after a failure or a model upgrade and picks up where it left off.
# force: re-identify and re-enrich even if done (e.g. a song named explicitly).
# retry_failed: also retry steps that previously failed or found no match.
#
# The library-wide steps (CreatorEmbeddings, FacetCalibration.recalibrate!) run
# separately, after a batch of songs.
class SongAnalysis
  RETRY_IDENTIFY = %w[unmatched error missing_file].freeze
  FAILED = "failed".freeze
  URL_EXPIRY = 15.minutes.to_i
  FEATURES = %w[bpm bpm_confidence key mode key_strength loudness danceability styles sound_embedding].freeze

  # Songs with any step outstanding.
  def self.pending(versions, retry_failed: false)
    scope = Song.unscoped.left_joins(:song_feature)
    unanalyzed = scope.where("song_features.sound_model_version IS DISTINCT FROM ?", versions["sound"])
                      .where.not(song_features: { identify_status: "missing_file" })
    unanalyzed = unanalyzed.where("song_features.sound_model_version IS DISTINCT FROM ?", FAILED) unless retry_failed
    pending = scope.where(song_features: { id: nil })
                   .or(scope.where(song_features: { identify_status: nil }))
                   .or(scope.where(song_features: { enriched_at: nil }))
                   .or(unanalyzed)
    if retry_failed
      pending = pending.or(scope.where(song_features: { identify_status: RETRY_IDENTIFY }))
                       .or(scope.where(song_features: { enrichment_status: "error" }))
    end
    pending.order(:id)
  end

  def initialize(song, client: AnalyzerClient.new, force: false, retry_failed: false)
    @song = song
    @client = client
    @force = force
    @retry_failed = retry_failed
  end

  def run
    @feature = @song.song_feature || @song.create_song_feature!
    tags_changed = false
    identify if identify?
    tags_changed |= analyze if analyze?
    tags_changed |= enrich if enrich?
    embed_genre if tags_changed || genre_stale?
    @feature
  end

  private

  def versions
    @client.versions
  end

  # Where the analyzer reads the song from: its path, when the analyzer mounts the
  # library too, or with ANALYZER_AUDIO=s3 a presigned GET for its object in
  # AWS_S3_BUCKET, when it can't (on Lambda). The library is that bucket mounted at
  # SONGS_DIRECTORY (s3fs), so the key is the path below it. Each call presigns
  # afresh, since a URL can expire while the song waits for the analyzer.
  def audio
    return { path: @song.path } unless ENV["ANALYZER_AUDIO"] == "s3"

    key = @song.path.delete_prefix("#{SONGS_DIRECTORY}/")
    presigner = Aws::S3::Presigner.new(client: Aws::S3::Client.new(region: ENV["AWS_REGION"]))
    { url: presigner.presigned_url(:get_object, bucket: ENV.fetch("AWS_S3_BUCKET"), key:, expires_in: URL_EXPIRY) }
  end

  # Embedded with an older model. (A song with no embedding has no tags to embed.)
  def genre_stale?
    @feature.genre_model_version.present? && @feature.genre_model_version != versions["genre"]
  end

  def identify?
    @feature.identify_status.nil? || @force || (@retry_failed && RETRY_IDENTIFY.include?(@feature.identify_status))
  end

  def analyze?
    return false if @feature.identify_status == "missing_file"
    return false if @feature.sound_model_version == FAILED && !@retry_failed

    @feature.analyzed_at.nil? || @feature.sound_model_version != versions["sound"]
  end

  def enrich?
    return false if @feature.identify_status.nil?

    @feature.enriched_at.nil? || @force || (@retry_failed && @feature.enrichment_status == "error")
  end

  # A hand-picked match from the admin MusicBrainz search is never second-guessed.
  # On "error" or "missing_file" any earlier match is kept.
  def identify
    if @song.musicbrainz_metadata.present? && @song.mb_recording_id
      status = "manual"
    else
      result = @client.identify(**audio, title: @song.title, artist: @song.artist.name,
                                album: @song.album&.title, duration: @song.time)
      status = result["status"]
      unless %w[error missing_file].include?(status)
        # update_columns: Song#reenrich must not mistake this for a hand-picked match.
        @song.update_columns(mb_recording_id: result["mb_recording_id"], acoustid: result["acoustid"] || @song.acoustid)
      end
    end
    @feature.update!(identify_status: status, identified_at: Time.current)
  end

  # Returns whether the song's tags changed.
  def analyze
    result = @client.analyze(**audio)
    SongFeature.transaction do
      @feature.update!(**result.slice(*FEATURES), sound_model_version: result["model_version"],
                       analyzed_at: Time.current)
      replace_tags("essentia", result["style_tags"])
    end
    true
  rescue AnalyzerClient::MissingFile
    false
  rescue AnalyzerClient::AnalysisFailed => e
    Rails.logger.warn("analyze failed for song #{@song.id}: #{e.message}")
    @feature.update!(sound_model_version: FAILED, analyzed_at: Time.current)
    false
  end

  # Only the sources the analyzer reached are replaced; the rest keep their data.
  def enrich
    album = @song.album
    result = @client.enrich(title: @song.title, artist: @song.artist.name, album: album&.title, year: @song.year,
                            id3_genre: album&.id3_genre, mb_recording_id: @song.mb_recording_id,
                            discogs_master_id: album&.discogs_master_id)
    if result["status"] == "error"
      @feature.update!(enrichment_status: "error", enriched_at: Time.current)
      return false
    end

    SongFeature.transaction do
      result["sources"].each do |source|
        replace_credits(source, result["credits"].select { |credit| credit["source"] == source })
      end
      result["tags"].each { |source, tags| replace_tags(source, tags) }
      link_ids(result, album)
      @feature.update!(release_year: result["release_year"], enrichment_status: result["status"],
                       enriched_at: Time.current)
    end
    true
  end

  def link_ids(result, album)
    @song.update_columns(mb_work_ids: result["mb_work_ids"]) if result.key?("mb_work_ids")
    artist = @song.artist
    artist.update_columns(mb_artist_id: result["mb_artist_id"]) if result["mb_artist_id"] && artist.mb_artist_id.nil?
    return unless album

    if result["mb_release_group_id"] && album.mb_release_group_id.nil?
      album.update_columns(mb_release_group_id: result["mb_release_group_id"])
    end
    album.update_columns(discogs_master_id: result["discogs_master_id"]) if result["discogs_master_id"]
  end

  def embed_genre
    tags = @song.song_tags.reload.map { |t| { tag: t.tag, weight: t.weight, source: t.source } }
    result = @client.genre_embedding(tags)
    @feature.update!(genre_embedding: result["embedding"],
                     genre_model_version: result["embedding"] && result["model_version"],
                     embedded_at: Time.current)
  end

  def replace_credits(source, credits)
    @song.credits.where(source:).delete_all
    credits.each do |credit|
      person = Person.for(name: credit["name"], mb_artist_id: credit["mb_artist_id"], discogs_id: credit["discogs_id"])
      @song.credits.find_or_initialize_by(person:, role: credit["role"], source:).update!(detail: credit["detail"])
    end
  end

  def replace_tags(source, tags)
    @song.song_tags.where(source:).delete_all
    tags.each { |tag, weight| @song.song_tags.create!(tag:, weight:, source:) }
  end
end
