json.extract! @artist, :id, :name, :sort, :slug, :created_at, :updated_at
json.songs @artist.songs, :id, :title, :sort, :slug, :track, :time, :featured, :live, :remix, :rating, :created_at, :updated_at
json.play_count @artist.plays.count
