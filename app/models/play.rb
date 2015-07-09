class Play < ActiveRecord::Base
  belongs_to :song
  has_one :artist, through: :song
  has_one :album, through: :song
  has_many :ratings
  default_scope {order(id: :desc)}
  before_create :tweet_song, if: "Rails.env.production?"
  after_create :send_to_live365, if: "Rails.env.production?"

  def self.next
    song = pick_random_song
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
    rescue Curl::Err::HostResolutionError, Curl::Err::ConnectionFailedError, Curl::Err::TimeoutError
      true
    end
  end

  def self.by_date(from = nil, to = nil)
    songs = unscoped
    songs = songs.where('playtime > ?', from) if from
    songs = songs.where('playtime < ?', to) if to
    songs
  end

  def self.song_ranks(from = nil, to = nil)
    songs = by_date(from, to)
    counts = songs.group(:song_id).order('count_song_id desc').count(:song_id)
  end

  def self.artist_ranks(from = nil, to = nil)
    songs = by_date(from, to).joins(:song)
    counts = songs.group(:artist_id).order('count_artist_id desc').count(:artist_id)
  end

  def self.album_ranks(from = nil, to = nil)
    songs = by_date(from, to).joins(:song).where('songs.album_id is not null')
    counts = songs.group(:album_id).order('count_album_id desc').count(:album_id)
  end

  private
    def twitter_message
      "Now playing: #{artist.name} - #{song.title}"
    end

    def self.pick_song_by_rating(rating)
      songs = Song.where('rating > ?', rating).where(featured: true).to_a
      return if songs.empty?
      begin
        candidate = songs.delete_at(Random.rand(songs.count))
        song = candidate if can_play?(candidate)
      end until song || songs.empty?
      song
    end

    def self.pick_random_song
      song = pick_song_by_rating(Random.rand * 100) until song
      song
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
