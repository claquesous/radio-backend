json.array!(@artists) do |artist|
  json.extract! artist, :id, :name, :sort, :slug
  json.url artist_url(artist, format: :json)
end
