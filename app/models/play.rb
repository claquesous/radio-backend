class Play < ActiveRecord::Base
  belongs_to :song
  has_one :artist, through: :song
  has_many :ratings
  default_scope {order(id: :desc)}
  before_create :tweet_song, if: "Rails.env.production?"
  after_create :send_to_live365, if: "Rails.env.production?"

  def self.next
    song = pick_random_song until can_play?(song)
    song.plays.build(playtime: Time.now)
  end

  def tweet_song
    begin
      process_replies
      tweet = $twitter_client.update twitter_message
      self.tweet_id = tweet.id
    rescue Twitter::Error
      true
    end
  end

  def send_to_live365
    begin
      Live365.send_metadata(song)
    rescue Curl::Err::HostResolutionError
      true
    end
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

    def rate_up(tweet)
      text = "@#{$twitter_client.user.screen_name} I love this song!"
      if tweet.full_text == text
        listener = Listener.find_or_create_by(twitter_handle: tweet.user.screen_name)
        Play.first.ratings.create(listener: listener, up: true)
      end
    end

    def rate_down(tweet)
      text = "@#{$twitter_client.user.screen_name} I hate this song!"
      if tweet.full_text == text
        listener = Listener.find_or_create_by(twitter_handle: tweet.user.screen_name)
        Play.first.ratings.create(listener: listener, up: false)
      end
    end

    def process_replies
      tweet_id = Play.first.tweet_id
      $twitter_client.mentions_timeline(since_id: tweet_id).each do |tweet|
        if tweet.in_reply_to_status_id == tweet_id.to_i
          rate_up tweet
          rate_down tweet
        end
      end if tweet_id
    end
end
