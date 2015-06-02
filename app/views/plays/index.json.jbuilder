json.array!(@plays) do |play|
  json.extract! play, :id, :artist, :ratings
  json.song play.song, :id, :album, :title, :sort, :slug, :track, :time, :featured, :live, :remix, :rating, :created_at, :updated_at
end
