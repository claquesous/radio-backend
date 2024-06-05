json.array!(@plays) do |play|
  json.extract! play, :id, :playtime, :tweet_id
  json.artist do
    json.extract! play.artist, :id, :name
  end
  json.song do
    json.extract! play.song, :id, :title
    json.rating @song_ratings[play.song.id]
  end
  json.album do
    json.extract! play.album, :id, :title if play.album
  end
end
