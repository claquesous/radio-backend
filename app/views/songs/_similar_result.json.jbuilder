json.extract! result.song, :id, :title, :slug
# songs.year is often blank; the analyzer's original release year fills in.
json.year result.song.year.presence || result.song.song_feature&.release_year
json.artist result.song.artist, :id, :name, :slug
json.album result.song.album, :id, :title, :slug if result.song.album
json.score result.score
json.scores result.scores
# Uncalibrated cosine similarities (and era decay), for debugging the blend.
json.details result.details
