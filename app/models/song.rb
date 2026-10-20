class Song < ApplicationRecord
  include Rankable
  include MusicbrainzLinked

  musicbrainz_id_column :mb_recording_id
  after_save :reenrich, if: :saved_change_to_mb_recording_id?
  after_commit :analyze, on: [:create, :update], if: -> { previously_new_record? || saved_change_to_mb_recording_id? }

  belongs_to :album, optional: true
  belongs_to :artist
  has_many :plays
  has_many :choosers, dependent: :destroy
  has_one :song_feature, dependent: :destroy
  has_many :credits, dependent: :destroy
  has_many :people, -> { distinct }, through: :credits
  has_many :song_tags, dependent: :destroy
  before_create :add_choosers
  before_destroy :prevent_destroy
  default_scope { order(:sort) }

  validates :title, presence: true

  # Bulk imports (rake radio:ingest) skip the per-song analysis job and are
  # backfilled with `rake recommendations:analyze` instead.
  def self.without_analysis
    previous = Thread.current[:skip_song_analysis]
    Thread.current[:skip_song_analysis] = true
    yield
  ensure
    Thread.current[:skip_song_analysis] = previous
  end

  private

  # A new recording match invalidates credits/tags.
  def reenrich
    song_feature&.update!(identify_status: "manual", enriched_at: nil)
  end

  def analyze
    return if Thread.current[:skip_song_analysis] || !AnalyzerClient.configured?

    AnalyzeSongJob.perform_later(id)
  end

  def prevent_destroy
    errors.add(:base, "Songs cannot be deleted")
    throw :abort
  end

  def add_choosers
    Stream.where(default_featured: true).each do |stream|
      choosers.build(stream: stream, rating: stream.default_rating)
    end
  end
end
