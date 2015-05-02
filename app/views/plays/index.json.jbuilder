json.array!(@plays) do |play|
  json.extract! play, :id, :song, :ratings
  json.url play_url(play, format: :json)
end
