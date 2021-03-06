class Song < ActiveRecord::Base
  belongs_to :album
  belongs_to :artist
  has_many :plays
  default_scope { order(rating: :desc).where(featured: true) }

  def rank(from = nil, to = nil)
    rank = Play.song_ranks(from,to).keys.index(id)
    rank + 1 if rank
  end
end
