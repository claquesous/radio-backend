json.extract! @song, :id, :artist_name_override, :title, :sort, :slug, :track, :time, :featured, :live, :remix, :rating, :year, :created_at, :updated_at
json.artist @song.artist, :id, :name, :slug
json.album @song.album, :id, :title, :slug if @song.album
