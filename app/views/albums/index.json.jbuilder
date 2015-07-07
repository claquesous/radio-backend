json.array!(@albums) do |album|
  json.extract! album, :id, :artist, :title, :sort, :slug, :tracks, :id3_genre, :record_label
end
