json.extract! @artist, :id, :name, :sort, :slug, :created_at, :updated_at, :musicbrainz_metadata
json.albums @artist.albums, :id, :title, :slug
json.songs @artist.songs, :id, :title, :sort, :slug, :track, :time, :featured, :live, :remix, :rating, :created_at, :updated_at
