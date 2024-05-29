json.extract! chooser, :id, :song_id, :stream_id, :featured, :rating, :created_at, :updated_at
json.url stream_chooser_url(chooser.stream, chooser, format: :json)
