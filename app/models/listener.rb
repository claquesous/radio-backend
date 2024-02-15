class Listener < ApplicationRecord
  validates_presence_of :twitter_handle
  has_many :requests
  has_many :ratings
end
