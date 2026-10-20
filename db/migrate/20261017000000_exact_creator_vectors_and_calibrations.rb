class ExactCreatorVectorsAndCalibrations < ActiveRecord::Migration[8.0]
  # Sparse TF-IDF over people, indexed by people.id: similarity only ever comes from
  # credits two songs actually share (the dense SVD version invented overlaps).
  CREATOR_DIMENSIONS = 1_000_000

  def up
    remove_index :song_features, :creator_embedding
    remove_column :song_features, :creator_embedding
    add_column :song_features, :creator_embedding, :sparsevec, limit: CREATOR_DIMENSIONS
    add_index :song_features, :creator_embedding, using: :hnsw, opclass: :sparsevec_cosine_ops
    execute "UPDATE song_features SET creator_model_version = NULL"

    # Raw cosine similarities sit on very different scales per facet (genre pairs
    # cluster near 0.95, sound near 0.6), so the recommender rescales each facet
    # between a typical pair (p50) and a near-identical one (p999) before blending.
    create_table :facet_calibrations do |t|
      t.string :facet, null: false, index: { unique: true }
      t.float :p50, null: false
      t.float :p90, null: false
      t.float :p99, null: false
      t.float :p999, null: false
      t.integer :sample_pairs, null: false
      t.string :model_version
      t.timestamps
    end
  end

  def down
    drop_table :facet_calibrations
    remove_index :song_features, :creator_embedding
    remove_column :song_features, :creator_embedding
    add_column :song_features, :creator_embedding, :vector, limit: 128
    add_index :song_features, :creator_embedding, using: :hnsw, opclass: :vector_cosine_ops
  end
end
