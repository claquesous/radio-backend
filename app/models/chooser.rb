class Chooser < ApplicationRecord
  belongs_to :song
  belongs_to :stream

  default_scope { order(rating: :desc) }
end
