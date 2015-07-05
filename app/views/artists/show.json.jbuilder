json.extract! @artist, :id, :name, :sort, :slug, :created_at, :updated_at
json.songs @artist.songs, :id, :title, :sort, :slug, :track, :time, :featured, :live, :remix, :rating, :created_at, :updated_at
json.play_count @artist.plays.count
json.last_played_at @artist.plays.first.try(:playtime)
json.previous_played_at @artist.plays.second.try(:playtime)
json.rank @artist.rank
json.last_week_rank @artist.rank(1.week.ago)
