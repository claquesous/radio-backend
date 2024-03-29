class Album < ApplicationRecord
  belongs_to :artist
  has_many :songs
  has_many :plays, through: :songs
  default_scope { order :sort }

  def rank(from = nil, to = nil)
    rank = Play.album_ranks(from,to).keys.index(id)
    rank + 1 if rank
  end
end
