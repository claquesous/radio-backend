class Stream < ApplicationRecord
  belongs_to :user
  has_many :choosers, dependent: :destroy
  before_create :add_choosers

  def add_choosers
    Song.all.each do |song|
      choosers.build(song: song, rating: song.rating, featured: song.featured)
    end
  end
end
