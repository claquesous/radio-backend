json.extract! chooser, :id, :stream_id, :rating, :created_at, :updated_at
json.song chooser.song, :id, :title
json.artist chooser.artist, :id, :name
