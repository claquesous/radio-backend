class Album < ApplicationRecord
  include Rankable

  belongs_to :artist
  has_many :songs, dependent: :restrict_with_error
  has_many :plays, through: :songs
  default_scope { order :sort }

  validates :title, presence: true
end
