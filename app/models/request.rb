class Request < ActiveRecord::Base
  belongs_to :song
  belongs_to :listener
end
