json.extract! @request, :played, :requested_at, :created_at
json.song @request.song, :id, :title
