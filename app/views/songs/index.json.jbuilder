if defined?(@pagination) && @pagination
  json.songs @songs do |song|
    json.extract! song, :id, :album, :artist, :artist_name_override, :title, :sort, :slug, :track, :time, :featured, :live, :remix, :rating, :year
  end
  json.total @pagination[:total]
else
  json.array! @songs do |song|
    json.extract! song, :id, :album, :artist, :artist_name_override, :title, :sort, :slug, :track, :time, :featured, :live, :remix, :rating, :year
  end
end
