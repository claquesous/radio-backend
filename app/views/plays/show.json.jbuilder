json.extract! @play, :id, :artist, :playtime, :tweet_id, :created_at, :updated_at
json.song @play.song, :id, :album, :title, :sort, :slug, :track, :time, :featured, :live, :remix, :rating, :created_at, :updated_at
json.stream @play.stream, :id, :name
