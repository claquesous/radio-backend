class Song < ActiveRecord::Base
  belongs_to :album
  belongs_to :artist
  has_many :plays
  default_scope { order(:sort).where(featured: true) }
end
