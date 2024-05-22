class Song < ApplicationRecord
  include SlugHelper

  belongs_to :album, optional: true
  belongs_to :artist
  has_many :plays
  default_scope { order(rating: :desc).where(featured: true) }

  def rank(from = nil, to = nil)
    rank = Play.song_ranks(from,to).keys.index(id)
    rank + 1 if rank
  end

  def s3_path
    "#{to_slug artist.name}/#{to_slug album.try(:title) || 'singles'}/#{to_slug title}"
  end

  def from_mp3_info(mp3_info)
    self.title = mp3_info.tag.title
    self.year = mp3_info.tag.year
    self.time = mp3_info.length
    self.path = SONGS_DIRECTORY + "/" + s3_path
    self.featured = true
    self.rating = 85
    self.sort = title.sub(/^The /, '')
  end
end

