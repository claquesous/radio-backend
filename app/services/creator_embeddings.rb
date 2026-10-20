# Rebuilds every song's creator_embedding from its credits: role-weighted TF-IDF
# over people, as a sparse vector indexed by people.id. Each vector is unit
# length, so cosine similarity is exactly the weighted overlap of shared credits
# and two songs with nobody in common score exactly 0. IDF keeps a session
# player credited on hundreds of songs from dominating.
#
# IDF depends on the whole library, so every vector is rebuilt together (about a
# second for a few thousand songs).
class CreatorEmbeddings
  MODEL_VERSION = "tfidf-sparse-v1".freeze
  DIMENSIONS = 1_000_000 # must match song_features.creator_embedding
  MAX_PEOPLE = 1000      # pgvector's HNSW limit on non-zero sparsevec entries
  BATCH_SIZE = 1000

  # How much sharing a person in each role says about two songs being alike.
  ROLE_WEIGHTS = {
    "producer" => 3.0, "composer" => 3.0, "lyricist" => 3.0, "writer" => 3.0,
    "performer" => 2.0, "vocal" => 2.0, "arranger" => 2.0,
    "instrument" => 1.0, "mixer" => 1.0, "engineer" => 0.5
  }.freeze

  def self.rebuild!
    embeddings = compute(Credit.pluck(:song_id, :person_id, :role))
    now = Time.current
    SongFeature.transaction do
      SongFeature.where.not(creator_embedding: nil).where.not(song_id: embeddings.keys)
                 .update_all(creator_embedding: nil, creator_model_version: nil, updated_at: now)
      embeddings.each_slice(BATCH_SIZE) do |batch|
        rows = batch.map do |song_id, weights|
          { song_id:, creator_embedding: Neighbor::SparseVector.new(weights, DIMENSIONS),
            creator_model_version: MODEL_VERSION, embedded_at: now }
        end
        SongFeature.upsert_all(rows, unique_by: :song_id)
      end
    end
    embeddings.size
  end

  # credits: [[song_id, person_id, role]] => { song_id => { person_id => weight } }
  def self.compute(credits)
    weights = Hash.new { |h, k| h[k] = {} }
    credits.each do |song_id, person_id, role|
      song = weights[song_id]
      song[person_id] = [song[person_id] || 0.0, ROLE_WEIGHTS.fetch(role, 1.0)].max
    end
    return {} if weights.empty?

    songs_per_person = Hash.new(0)
    weights.each_value { |people| people.each_key { |person_id| songs_per_person[person_id] += 1 } }
    total = weights.size

    weights.to_h do |song_id, people|
      tfidf = people.to_h { |p, w| [p, w * (Math.log((1.0 + total) / (1 + songs_per_person[p])) + 1)] }
      top = tfidf.max_by(MAX_PEOPLE) { |_, w| w }
      norm = Math.sqrt(top.sum { |_, w| w * w })
      [song_id, top.select { |p, _| p < DIMENSIONS }.to_h { |p, w| [p, w / norm] }]
    end
  end
end
