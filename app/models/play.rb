class Play < ApplicationRecord
  belongs_to :stream
  belongs_to :song
  has_one :artist, through: :song
  has_one :album, through: :song
  has_many :ratings
  has_many :requests
  default_scope {order(id: :desc)}
  before_create :toot_song, :if => proc { Rails.env.production? }
  after_create :resolve_requests

  def toot_song
    begin
      client = if stream.mastodon_access_token.present? && stream.mastodon_url.present?
        Mastodon::REST::Client.new(base_url: stream.mastodon_url, bearer_token: stream.mastodon_access_token)
      else
        Mastodon::REST::Client.new(base_url: ENV['MASTODON_URL'], bearer_token: ENV['MASTODON_ACCESS_TOKEN'])
      end
      toot = client.create_status(mastodon_message, visibility: 'unlisted')
      self.tweet_id = toot.id
    rescue FrozenError, HTTP::TimeoutError
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

  def resolve_requests
    stream.requests.where(song: song).where(played: false).update_all(played: true, play_id: id)
  end

  private
    def mastodon_message
      "Now playing: #{artist.name} - #{song.title}"
    end

end
