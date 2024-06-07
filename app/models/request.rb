class Request < ApplicationRecord
  belongs_to :stream
  belongs_to :song
  belongs_to :user
  belongs_to :play, optional: true
  validate :not_throttled

  scope :eligible_to_play, -> { where('requested_at < ?', 1.hour.ago).where(played: false) }

  USER_REQUESTS_PER_HOUR = 3

  private

  def not_throttled
    return if user == stream.user
    antepenultimate = user.requests.order(requested_at: :desc).limit(USER_REQUESTS_PER_HOUR).third
    if antepenultimate.present? && antepenultimate.requested_at > 1.hour.ago
      errors.add(:user, "can't request more than #{USER_REQUESTS_PER_HOUR} songs an hour")
    end
  end
end

