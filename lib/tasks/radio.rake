require 'mp3info'

namespace :radio do
  def add_artist(name)
    artist = Artist.find_or_initialize_by(name: name) do |artist|
      artist.sort = name.sub(/^The /, '')
    end
    artist.save! and puts "Ingest Artist: #{name}" unless artist.persisted?
    artist
  end

  def add_album(title, artist)
    album = artist.albums.find_or_initialize_by(title: title) do |album|
      album.sort = title.sub(/^The /, '')
    end
    album.save! and puts "Ingest Album: #{title}" unless album.persisted?
    album
  end

  def add_details(path, artist_name, song_title, tracknum=nil, album_title=nil)
    artist = add_artist artist_name
    album = add_album album_title, artist if album_title

    song = artist.songs.find_or_initialize_by(title: song_title) do |song|
      song.time = Mp3Info.open(path).length
      song.path = path
      song.album = album
      song.track = tracknum
      song.featured = true
      song.rating = 85
      song.sort = song_title.sub(/^The /, '')
    end
    song.save! and puts "Ingest Song: #{song_title}" unless song.persisted?
  end


  desc "Ingests from given directory"
  task ingest: :environment do
    directory = ENV['INGEST_DIRECTORY']
    abort "Please set INGEST_DIRECTORY environment variable" unless directory
    f = File.open File.join(directory, "all.m3u")
    f.readlines.each do |path|
      slice = path.strip.split(/[\\\/]/).slice(-3,3)
      artist,album,track = slice
      path = File.join(slice.unshift(directory))
      /(?<tracknum>\d\d) (?<title>.*)\.mp3/ =~ track
      Song.find_by_path(path) || add_details(path,artist,title,tracknum,album)
    end
    Dir.glob("#{directory}/Promo/**/*.mp3").each do |path|
      mp3_info = Mp3Info.open(path)
      artist = mp3_info.tag.artist
      title = mp3_info.tag.title
      Song.find_by_path(path) || add_details(path,artist,title)
    end
  end

end
