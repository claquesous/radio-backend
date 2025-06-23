class Artist < ApplicationRecord
  include Rankable

  default_scope { order :sort }
  has_many :songs
  has_many :albums
  has_many :plays, through: :songs

  validates :name, presence: true
end
