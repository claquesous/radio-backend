class Album < ApplicationRecord
  include Rankable
  include MusicbrainzLinked

  musicbrainz_id_column :mb_release_group_id

  belongs_to :artist
  has_many :songs, dependent: :restrict_with_error
  has_many :plays, through: :songs
  default_scope { order :sort }

  validates :title, presence: true
end
