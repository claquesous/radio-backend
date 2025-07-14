class Chooser < ApplicationRecord
  belongs_to :song
  belongs_to :stream

  delegate :artist, to: :song

  default_scope { order(rating: :desc) }

  before_destroy :prevent_destroy_if_stream_would_violate_threshold

  private

    def prevent_destroy_if_stream_would_violate_threshold
      return unless stream.enabled?

      remaining_choosers = stream.choosers.where.not(id: id)
      unless stream.validate_chooser_set(remaining_choosers)
        errors.add(:base, "Cannot delete chooser: would violate stream requirements")
        throw(:abort)
      end
    end
end
