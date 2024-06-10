json.extract! @song, :id, :album, :artist, :artist_name_override, :title, :sort, :slug, :track, :time, :featured, :live, :remix, :rating, :year, :created_at, :updated_at
json.play_count @song.plays.count
json.last_played_at @song.plays.first.try(:playtime)
json.previous_played_at @song.plays.second.try(:playtime)
json.rank @song.rank
json.last_week_rank @song.rank(1.week.ago)
