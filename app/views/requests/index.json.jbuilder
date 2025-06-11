json.array!(@requests) do |request|
  json.extract! request, :id, :user_id, :played, :requested_at
  json.song request.song, :id, :title
end
