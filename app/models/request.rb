class Request < ApplicationRecord
  belongs_to :stream
  belongs_to :song
  belongs_to :user

  scope :eligible_to_play, -> { where('requested_at < ?', 1.hour.ago).where(played: false) }
end
