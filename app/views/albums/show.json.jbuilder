json.extract! @album, :id, :title, :sort, :slug, :tracks, :id3_genre, :record_label, :created_at, :updated_at, :musicbrainz_metadata
json.artist @album.artist, :id, :name, :slug, :musicbrainz_metadata
json.songs @album.songs, :id, :title, :sort, :slug
