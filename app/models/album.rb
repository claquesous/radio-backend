class Album < ApplicationRecord
  include Rankable

  belongs_to :artist
  has_many :songs
  has_many :plays, through: :songs
  default_scope { order :sort }
end
