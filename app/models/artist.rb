class Artist < ApplicationRecord
  default_scope { order :sort }
  has_many :songs
  has_many :albums
  has_many :plays, through: :songs

  def rank(from = nil, to = nil)
    rank = Play.artist_ranks(from,to).keys.index(id)
    rank + 1 if rank
  end
end
