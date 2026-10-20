class CreateSongFeatures < ActiveRecord::Migration[8.0]
  def change
    create_table :song_features do |t|
      t.references :song, null: false, foreign_key: true, index: { unique: true }

      # identify: fpcalc -> AcoustID -> MusicBrainz recording
      t.string :identify_status
      t.datetime :identified_at

      # analyze: Essentia
      t.float :bpm
      t.float :bpm_confidence
      t.integer :key            # pitch class, 0 = C
      t.string :mode            # major / minor
      t.float :key_strength
      t.float :loudness
      t.float :danceability
      t.jsonb :styles           # Discogs-400 style probabilities above a floor
      t.vector :sound_embedding, limit: 1280
      t.string :sound_model_version
      t.datetime :analyzed_at

      # enrich: MusicBrainz / Discogs
      t.integer :release_year
      t.string :enrichment_status
      t.datetime :enriched_at

      # embed: derived from credits and song_tags
      t.vector :creator_embedding, limit: 128
      t.string :creator_model_version
      t.vector :genre_embedding, limit: 384
      t.string :genre_model_version
      t.datetime :embedded_at

      t.timestamps
    end

    add_index :song_features, :sound_embedding, using: :hnsw, opclass: :vector_cosine_ops
    add_index :song_features, :creator_embedding, using: :hnsw, opclass: :vector_cosine_ops
    add_index :song_features, :genre_embedding, using: :hnsw, opclass: :vector_cosine_ops
    add_index :song_features, :release_year
  end
end
