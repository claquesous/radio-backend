class Live365

  def self.send_metadata(song)
    args = {
      member_name: ENV['LIVE365_USER'],
      password: ENV['LIVE365_PASSWORD'],
      version: 2,
      title: song.title,
      artist: song.artist.name,
      seconds: song.time
    }
    args[:album] = song.album.title if song.album

    Curl.post("http://www.live365.com/cgi-bin/add_song.cgi", args)
  end

end
