class Album < ActiveRecord::Base
  belongs_to :artist
  default_scope { order :sort }
end
