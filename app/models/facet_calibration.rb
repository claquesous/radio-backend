# Each facet's similarity scale, measured over a sample of song pairs by
# recalibrate! (run after a batch of songs is analyzed).
class FacetCalibration < ApplicationRecord
  # Calibrated score at each anchor: a typical pair is 0, the closest 1% of pairs
  # 0.75, the closest 0.1% 0.95, and an identical pair 1. Piecewise linear between,
  # so the strongest matches stay distinguishable instead of all capping at 1.
  ANCHORS = { p50: 0.0, p99: 0.75, p999: 0.95 }.freeze
  SAMPLE_PAIRS = 200_000
  PERCENTILES = { p50: 0.5, p90: 0.9, p99: 0.99, p999: 0.999 }.freeze

  # facet => [embedding column, model version column]
  COLUMNS = {
    "sound" => %w[sound_embedding sound_model_version],
    "creators" => %w[creator_embedding creator_model_version],
    "genre" => %w[genre_embedding genre_model_version]
  }.freeze

  validates :facet, presence: true, uniqueness: true

  # Measures every facet's p50/p90/p99/p999 cosine similarity over song pairs:
  # all pairs for a small library, a uniform random sample otherwise.
  def self.recalibrate!(sample_pairs: SAMPLE_PAIRS)
    COLUMNS.filter_map do |facet, (column, version_column)|
      stats = measure(column, sample_pairs)
      next unless stats

      version = SongFeature.where.not(column => nil).group(version_column).order(Arel.sql("count(*) DESC"))
                           .limit(1).pluck(version_column).first
      find_or_initialize_by(facet:).tap { |c| c.update!(**stats, model_version: version) }
    end
  end

  def self.measure(column, sample_pairs)
    count = SongFeature.where.not(column => nil).count
    return nil if count < 2

    pairs = if count * (count - 1) / 2 <= sample_pairs
              "SELECT a.i, b.i AS j FROM v a JOIN v b ON a.i < b.i"
            else
              <<~SQL
                SELECT i, j FROM (
                  SELECT 1 + floor(random() * #{count})::int AS i, 1 + floor(random() * #{count})::int AS j
                  FROM generate_series(1, #{sample_pairs.to_i})
                ) r WHERE i <> j
              SQL
            end
    transaction do
      connection.execute("SELECT setseed(0)")
      row = connection.select_one(<<~SQL)
        WITH v AS (
          SELECT row_number() OVER (ORDER BY song_id) AS i, #{column} AS e
          FROM song_features WHERE #{column} IS NOT NULL
        ), pairs AS (#{pairs})
        SELECT count(*) AS sample_pairs,
               #{PERCENTILES.map { |name, q| "percentile_cont(#{q}) WITHIN GROUP (ORDER BY s) AS #{name}" }.join(", ")}
        FROM (SELECT 1 - (a.e <=> b.e) AS s FROM pairs JOIN v a ON a.i = pairs.i JOIN v b ON b.i = pairs.j) similarities
      SQL
      row.symbolize_keys
    end
  end

  def normalize(similarity)
    points = ANCHORS.map { |column, score| [self[column], score] } + [[1.0, 1.0]]
    return similarity.clamp(0.0, 1.0) unless points.each_cons(2).all? { |(a, _), (b, _)| b > a }
    return 0.0 if similarity <= points.first.first

    (low_raw, low_score), (high_raw, high_score) = points.each_cons(2).find { |_, (raw, _)| similarity <= raw } ||
                                                   points.last(2)
    (low_score + (similarity - low_raw) / (high_raw - low_raw) * (high_score - low_score)).clamp(0.0, 1.0)
  end
end
