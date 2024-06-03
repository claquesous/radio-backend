class Stream < ApplicationRecord
  belongs_to :user
  has_many :choosers, dependent: :destroy
  has_many :plays
  has_many :requests
  before_create :add_choosers

  def add_choosers
    Song.all.each do |song|
      choosers.build(song: song, rating: song.rating, featured: song.featured)
    end
  end

  def next_play
    plays.build(playtime: Time.now, song: pick_requested_song || pick_random_song)
  end

  def by_date(from = nil, to = nil)
    plays = self.plays.unscoped
    plays = plays.where('playtime > ?', from) if from
    plays = plays.where('playtime < ?', to) if to
    plays
  end

  def song_ranks(from = nil, to = nil)
    plays = by_date(from, to)
    plays.group(:song_id).order('count_song_id desc').count(:song_id)
  end

  def artist_ranks(from = nil, to = nil)
    plays = by_date(from, to).joins(:song)
    plays.group(:artist_id).order('count_artist_id desc').count(:artist_id)
  end

  def album_ranks(from = nil, to = nil)
    plays = by_date(from, to).joins(:song).where('songs.album_id is not null')
    plays.group(:album_id).order('count_album_id desc').count(:album_id)
  end

  private

    def pick_song_by_rating(rating)
      options = choosers.where(featured: true).where('rating > ?', rating).to_a
      until options.empty?
        candidate = options.delete_at(Random.rand(options.count)).song
        return candidate if can_play?(candidate)
      end
    end

    def pick_requested_song
      requests.eligible_to_play.detect do |request|
        can_play?(request.song)
      end&.song
    end

    def pick_random_song
      song = pick_song_by_rating(Random.rand * 100) until song
      song
    end

    def can_play?(song)
      return false unless song
      plays.limit(80).includes(:song, :artist).each_with_index do |play, i|
        return false if play.song == song || (i<40 && play.artist == song.artist)
      end
      true
    end
end
