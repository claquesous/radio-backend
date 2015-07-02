json.array!(@plays) do |play|
  json.extract! play, :id, :artist, :playtime, :tweet_id
  json.song play.song, :id, :album, :title, :sort, :slug, :track, :time, :featured, :live, :remix, :rating, :created_at, :updated_at
end
