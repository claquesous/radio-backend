class SongTag < ApplicationRecord
  SOURCES = %w[musicbrainz discogs essentia id3 manual].freeze

  belongs_to :song

  validates :tag, presence: true
  validates :source, inclusion: { in: SOURCES }
  validates :tag, uniqueness: { scope: [:song_id, :source] }
end
