class Play < ApplicationRecord
  belongs_to :stream
  belongs_to :song
  has_one :artist, through: :song
  has_one :album, through: :song
  has_many :ratings
  default_scope {order(id: :desc)}
  before_create :toot_song, :if => proc { Rails.env.production? }

  def self.next
    song = pick_random_song
    song.plays.build(playtime: Time.now)
  end

  def toot_song
    begin
      toot = $mastodon_client.create_status(mastodon_message, visibility: 'unlisted')
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

  private
    def mastodon_message
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

end
