json.array!(@plays) do |play|
  json.extract! play, :id, :song, :artist, :ratings
end
