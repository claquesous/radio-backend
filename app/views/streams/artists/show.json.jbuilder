json.extract! @artist, :id, :name, :musicbrainz_metadata
json.songs @songs do |song|
  json.extract! song, :id, :title
  json.rating @song_ratings[song.id]
end
json.play_count @play_count
json.last_played_at @last_played_at
json.previous_played_at @previous_played_at
json.rank @rank
json.last_week_rank @last_week_rank
