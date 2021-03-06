json.extract! @album, :id, :artist, :title, :sort, :slug, :tracks, :id3_genre, :record_label, :created_at, :updated_at
json.songs @album.songs, :id, :title, :sort, :slug, :track, :time, :featured, :live, :remix, :rating, :created_at, :updated_at
json.play_count @album.plays.count
json.last_played_at @album.plays.first.try(:playtime)
json.previous_played_at @album.plays.second.try(:playtime)
json.rank @album.rank
json.last_week_rank @album.rank(1.week.ago)
