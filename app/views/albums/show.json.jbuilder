json.extract! @album, :id, :title, :sort, :slug, :tracks, :id3_genre, :record_label, :created_at, :updated_at
json.artist @album.artist, :id, :name, :slug
json.songs @album.songs, :id, :title, :sort, :slug
