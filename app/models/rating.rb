class Rating < ApplicationRecord
  belongs_to :play
  belongs_to :user
  has_one :song, through: :play
  has_one :stream, through: :play
  before_create :update_rating
  validate :latest_play

  def update_rating
    chooser = stream.choosers.where(song: song).first
    old = chooser.rating
    diff = (100*old-(old*old))/500
    chooser.rating = chooser.rating.send( up ? :+ : :-, diff)
    chooser.save!
  end

  def latest_play
    if (play != stream.plays.first)
      errors.add(:play, "must be the most recent")
    end
  end
end

