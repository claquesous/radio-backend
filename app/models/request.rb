class Request < ApplicationRecord
  belongs_to :stream
  belongs_to :song
  belongs_to :listener
end
