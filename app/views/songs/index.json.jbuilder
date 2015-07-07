json.array!(@songs) do |song|
  json.extract! song, :id, :album, :artist, :title, :sort, :slug, :track, :time, :featured, :live, :remix, :rating
end
