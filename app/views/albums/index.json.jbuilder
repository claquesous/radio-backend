json.array!(@albums) do |album|
  json.extract! album, :id, :artist_id, :title, :sort, :slug, :tracks, :id3_genre, :record_label
  json.url album_url(album, format: :json)
end
