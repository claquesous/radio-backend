json.extract! @song, :id, :album, :artist_id, :title, :sort, :slug, :track, :time, :featured, :live, :remix, :rating, :created_at, :updated_at
json.play_count @song.plays.count
