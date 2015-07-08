class Live365

  def self.send_metadata(song)
    args = {
      member_name: ENV['LIVE365_USER'],
      password: ENV['LIVE365_PASSWORD'],
      version: 2,
      title: song.title,
      artist: song.artist.name,
      album: song.album.try(:title) || "Single",
      seconds: song.time
    }

    Curl.post("http://www.live365.com/cgi-bin/add_song.cgi", args) do |curl|
      curl.timeout = 3 # No need to wait for a response
    end
  end

end
