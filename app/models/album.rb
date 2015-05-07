class Album < ActiveRecord::Base
  belongs_to :artist
  has_many :songs
  default_scope { order :sort }
end
