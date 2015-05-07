class Artist < ActiveRecord::Base
  default_scope { order :sort }
  has_many :songs
  has_many :albums
end
