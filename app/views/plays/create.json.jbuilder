json.extract! @play, :id, :artist, :ratings, :playtime, :tweet_id, :created_at, :updated_at
json.song @play.song, :id, :album, :title, :sort, :slug, :track, :time, :featured, :live, :remix, :rating, :path, :created_at, :updated_at
