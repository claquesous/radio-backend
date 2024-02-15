class Rating < ApplicationRecord
  belongs_to :play
  belongs_to :listener
  has_one :song, through: :play
  before_create :update_rating

  def update_rating
    old = song.rating
    diff = (100*old-(old*old))/500;
    song.rating = song.rating.send( up ? :+ : :-, diff)
    song.save!
  end
end
