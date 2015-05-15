class Play < ActiveRecord::Base
  belongs_to :song
  has_one :artist, through: :song
  default_scope {order(id: :desc)}
  before_create :tweet_song
  after_create :send_to_live365

  def self.next
    song = pick_random_song until can_play?(song)
    song.plays.build(playtime: Time.now)
  end

  def tweet_song
    begin
      tweet = $twitter_client.update twitter_message
      self.tweet_id = tweet.id
    rescue Twitter::Error
      true
    end
  end

  def send_to_live365
    Live365.send_metadata(song)
  end

  private
    def twitter_message
      "Now playing: #{artist.name} - #{song.title}"
    end

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
