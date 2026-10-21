json.partial! "streams/stream", stream: @stream
if policy(@stream).show?
  json.default_rating @stream.default_rating
  json.default_featured @stream.default_featured
  json.mastodon_url @stream.mastodon_url
end

if policy(@stream).update?
  # Progress toward the variety a stream needs before it can be enabled.
  json.playlist do
    json.songs @stream.choosers.count
    json.artists @stream.choosers.joins(:song).distinct.count("songs.artist_id")
    json.required_songs (Stream::SONG_REPEAT_WINDOW * Stream::VARIETY_FACTOR).ceil
    json.required_artists (Stream::ARTIST_REPEAT_WINDOW * Stream::VARIETY_FACTOR).ceil
    # False until radio-analyzer has analyzed some songs; the playlist page then
    # hides its similar-song suggestions.
    json.similar_songs_available Recommender.available?
  end
end
