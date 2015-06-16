json.extract! @album, :id, :artist_id, :title, :sort, :slug, :tracks, :id3_genre, :record_label, :created_at, :updated_at
json.songs @album.songs, :id, :title, :sort, :slug, :track, :time, :featured, :live, :remix, :rating, :created_at, :updated_at
json.play_count @album.plays.count
