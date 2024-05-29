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
    plays.build(playtime: Time.now, song: pick_random_song)
  end

  private

    def pick_song_by_rating(rating)
      options = choosers.where(featured: true).where('rating > ?', rating).to_a
      until options.empty?
        candidate = options.delete_at(Random.rand(options.count)).song
        return candidate if can_play?(candidate)
      end
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
