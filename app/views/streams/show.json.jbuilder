json.partial! "streams/stream", stream: @stream
if policy(@stream).show?
  json.default_rating @stream.default_rating
  json.default_featured @stream.default_featured
  json.mastodon_url @stream.mastodon_url
end

