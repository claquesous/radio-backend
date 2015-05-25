json.array!(@artists) do |artist|
  json.extract! artist, :id, :name, :sort, :slug
end
