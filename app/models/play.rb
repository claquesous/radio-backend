class Play < ActiveRecord::Base
  belongs_to :song
  has_one :artist, through: :song
  default_scope {order(id: :desc).limit(25)}

  def self.next
    song = pick_random_song until can_play?(song)
    song.plays.build(playtime: Time.now)
  end

  private
    def self.pick_random_song
      rating = Random.rand * 100
      songs = Song.where('rating > ?', rating).where(featured: true)
      songs[Random.rand(songs.count)] if songs.any?
    end

    def self.can_play?(song)
      return false unless song
      limit(80).includes(:song, :artist).each_with_index do |play, i|
        return false if play.song == song || (i<40 && play.artist == song.artist)
      end
      true
    end
end
