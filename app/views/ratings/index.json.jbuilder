json.array!(@ratings) do |rating|
  json.extract! rating, :id, :play, :up, :twitter_handle
  json.url rating_url(rating, format: :json)
end
