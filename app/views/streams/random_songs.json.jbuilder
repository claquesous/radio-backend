json.results @songs do |song|
  json.extract! song, :id, :title, :slug
  json.year song.year.presence || song.song_feature&.release_year
  json.artist song.artist, :id, :name, :slug
  json.album song.album, :id, :title, :slug if song.album
end
