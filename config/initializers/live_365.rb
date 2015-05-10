class Live365

  def self.send_metadata(song)
    Curl.post("http://www.live365.com/cgi-bin/add_song.cgi", {
      member_name: ENV['LIVE365_USER'],
      password: ENV['LIVE365_PASSWORD'],
      version: 2,
      title: song.title,
      artist: song.artist.name,
      album: song.album.title,
      seconds: song.time
    })
  end

end
