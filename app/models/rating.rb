class Rating < ActiveRecord::Base
  belongs_to :play
  belongs_to :listener
end
