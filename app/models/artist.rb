class Artist < ApplicationRecord
  include Rankable

  default_scope { order :sort }
  has_many :songs, dependent: :restrict_with_error
  has_many :albums, dependent: :restrict_with_error
  has_many :plays, through: :songs

  validates :name, presence: true
end
