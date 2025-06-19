json.extract! chooser, :id, :stream_id, :featured, :rating, :created_at, :updated_at
json.song chooser.song, :id, :title
json.artist chooser.artist, :id, :name
