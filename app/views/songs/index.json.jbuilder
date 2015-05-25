json.array!(@songs) do |song|
  json.extract! song, :id, :album, :artist_id, :title, :sort, :slug, :track, :time, :featured, :live, :remix, :rating, :path
end
