class Song < ApplicationRecord
  include Rankable

  belongs_to :album, optional: true
  belongs_to :artist
  has_many :plays
  has_many :choosers, dependent: :destroy
  before_create :add_choosers
  before_destroy :prevent_destroy
  default_scope { order(:sort) }

  validates :title, presence: true

  private

  def prevent_destroy
    errors.add(:base, "Songs cannot be deleted")
    throw :abort
  end

  def add_choosers
    Stream.all.each do |stream|
      choosers.build(stream: stream, rating: stream.default_rating, featured: stream.default_featured)
    end
  end
end
