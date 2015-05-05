json.array!(@plays) do |play|
  json.extract! play, :id, :song, :artist, :ratings
  json.url play_url(play, format: :json)
end
