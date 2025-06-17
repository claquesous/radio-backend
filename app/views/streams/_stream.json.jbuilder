json.extract! stream, :id, :name, :user_id, :default_rating, :default_featured, :mastodon_url, :mastodon_access_token, :created_at, :updated_at
json.url stream_url(stream, format: :json)
