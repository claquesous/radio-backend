class Rating < ApplicationRecord
  belongs_to :play
  belongs_to :listener, optional: true
  has_one :song, through: :play
  before_create :update_rating

  def update_rating
    chooser = play.stream.choosers.where(song: song).first
    old = chooser.rating
    diff = (100*old-(old*old))/500
    chooser.rating = chooser.rating.send( up ? :+ : :-, diff)
    chooser.save!
  end
end

