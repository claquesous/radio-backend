class Song < ApplicationRecord
  include Rankable

  belongs_to :album, optional: true
  belongs_to :artist
  has_many :plays
  has_many :choosers, dependent: :destroy
  before_create :add_choosers
  default_scope { order(:sort) }

  validates :title, presence: true

  def add_choosers
    Stream.all.each do |stream|
      choosers.build(stream: stream, rating: stream.default_rating, featured: stream.default_featured)
    end
  end
end

