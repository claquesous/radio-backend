namespace :radio do
  def add_details
    artist = Artist.find_or_initialize_by(name: @artist) do |artist|
      artist.sort = @artist.sub(/^The /, '')
    end
    artist.save and puts "Ingest Artist: #{@artist}" unless artist.persisted?
    album = artist.albums.find_or_initialize_by(title: @album) do |album|
      album.sort = @album.sub(/^The /, '')
    end
    album.save and puts "Ingest Album: #{@album}" unless album.persisted?

    /(?<tracknum>\d\d) (?<title>.*)\.mp3/ =~ @track
    song = album.songs.find_or_initialize_by(title: title) do |song|
      song.path = @path
      song.artist = artist
      song.track = tracknum
      song.featured = true
      song.rating = 85
      song.sort = title.sub(/^The /, '')
    end
    song.save and puts "Ingest Song: #{title}" unless song.persisted?
  end


  desc "Ingests from given directory"
  task ingest: :environment do
    directory = ENV['INGEST_DIRECTORY']
    abort "Please set INGEST_DIRECTORY environment variable" unless directory
    f = File.open File.join(directory, "all.m3u")
    f.readlines.each do |path|
      slice = path.strip.split(/[\\\/]/).slice(-3,3)
      @artist,@album,@track = slice
      @path = File.join(slice.unshift(directory))
      Song.find_by_path(@path) || add_details
    end
  end

end
