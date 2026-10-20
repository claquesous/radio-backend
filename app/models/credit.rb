class Credit < ApplicationRecord
  ROLES = %w[performer vocal instrument producer engineer mixer composer lyricist writer arranger].freeze
  SOURCES = %w[musicbrainz discogs manual].freeze

  belongs_to :song
  belongs_to :person

  validates :role, inclusion: { in: ROLES }
  validates :source, inclusion: { in: SOURCES }
  validates :person_id, uniqueness: { scope: [:song_id, :role, :source] }
end
