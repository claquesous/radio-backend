class Chooser < ApplicationRecord
  belongs_to :song
  belongs_to :stream

  delegate :artist, to: :song

  default_scope { order(rating: :desc) }
end
