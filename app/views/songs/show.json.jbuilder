json.extract! @song, :id, :artist_name_override, :title, :sort, :slug, :track, :time, :featured, :live, :remix, :rating, :year, :created_at, :updated_at, :musicbrainz_metadata
json.artist @song.artist, :id, :name, :slug, :musicbrainz_metadata
json.album @song.album, :id, :title, :slug, :musicbrainz_metadata if @song.album
json.features do
  feature = @song.song_feature
  json.extract! feature, :bpm, :key, :mode, :release_year, :danceability, :loudness if feature
  json.tags @song.song_tags.order(weight: :desc).limit(10).pluck(:tag).uniq
end
