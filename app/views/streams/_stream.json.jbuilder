json.extract! stream, :id, :name, :user_id, :premium, :genre, :description, :enabled, :created_at, :updated_at
json.url stream_url(stream, format: :json)
