class Stream < ApplicationRecord
  SONG_REPEAT_WINDOW = 80
  ARTIST_REPEAT_WINDOW = 40
  VARIETY_FACTOR = 1.5
  MIN_CHOOSERS_REQUIRED = SONG_REPEAT_WINDOW * VARIETY_FACTOR

  belongs_to :user
  has_many :choosers, dependent: :destroy
  has_many :plays
  has_many :requests
  validate :default_rating_in_range
  validate :cannot_enable_on_create, on: :create
  validate :sufficient_choosers_when_enabled
  before_destroy :prevent_destroy_if_enabled

  after_commit :publish_stream_events

  attr_encrypted :mastodon_access_token, key: ENV['MASTODON_ACCESS_TOKEN_KEY']


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

  def validate_chooser_set(chooser_set)
    unique_artists = chooser_set.joins(:song).distinct.count('songs.artist_id')
    extra_songs = SONG_REPEAT_WINDOW - unique_artists
    required_variety = (ARTIST_REPEAT_WINDOW * VARIETY_FACTOR).ceil

    unless chooser_set.count >= MIN_CHOOSERS_REQUIRED && extra_songs > required_variety
      errors.add(:enabled, "cannot be enabled: not enough playlist variety")
      return false
    end

    true
  end

  private

    def pick_song_by_rating(rating)
      options = choosers.where('rating > ?', rating).to_a
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
      plays.limit(SONG_REPEAT_WINDOW).includes(:song, :artist).each_with_index do |play, i|
        return false if play.song == song || (i < ARTIST_REPEAT_WINDOW && play.artist == song.artist)
      end
      true
    end

    def default_rating_in_range
      if default_rating<0 || default_rating>100
        errors.add(:default_rating, "must be from 0 to 100")
      end
    end

    def cannot_enable_on_create
      if enabled
        errors.add(:enabled, "cannot be true at creation")
      end
    end

    def prevent_destroy_if_enabled
      if enabled
        errors.add(:base, "Cannot destroy an enabled stream")
        throw(:abort)
      end
    end

    def sufficient_choosers_when_enabled
      return unless enabled_changed? && enabled
      validate_chooser_set(choosers)
    end

    def publish_stream_events
      if saved_change_to_enabled?
        if saved_change_to_enabled == [false, true]
          StreamEventPublisher.publish(:stream_created, self)
        elsif saved_change_to_enabled == [true, false]
          StreamEventPublisher.publish(:stream_destroyed, self)
        end
      elsif enabled && (saved_change_to_name? || saved_change_to_premium? || saved_change_to_description? || saved_change_to_genre?)
        StreamEventPublisher.publish(:stream_updated, self)
      end
    rescue => e
      Rails.logger.error "Failed to publish stream event: #{e.message}"
    end
end
