if defined?(@pagination) && @pagination
  json.artists @artists do |artist|
    json.extract! artist, :id, :name, :sort, :slug
  end
  json.total @pagination[:total]
else
  json.array! @artists do |artist|
    json.extract! artist, :id, :name, :sort, :slug
  end
end
