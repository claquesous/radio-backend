json.array!(@requests) do |request|
  json.extract! request, :id, :twitter_handle, :song, :requested_at
  json.url request_url(request, format: :json)
end
