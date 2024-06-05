json.extract! @song, :id, :title
json.artist do
  json.extract! @song.artist, :id, :name
end
json.rating @rating
json.play_count @play_count
json.last_played_at @last_played_at
json.previous_played_at @previous_played_at
json.rank @rank
json.last_week_rank @last_week_rank

