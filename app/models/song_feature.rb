class SongFeature < ApplicationRecord
  belongs_to :song

  has_neighbors :sound_embedding, :creator_embedding, :genre_embedding

  MODES = %w[major minor].freeze

  validates :key, inclusion: { in: 0..11 }, allow_nil: true
  validates :mode, inclusion: { in: MODES }, allow_nil: true
end
