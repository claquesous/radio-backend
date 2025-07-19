module Streams
  class ArtistsController < ApplicationController
    skip_before_action :authenticate_request

    # GET /streams/1/artists/1.json
    def show
      stream = Stream.find(params[:stream_id])
      @artist = Artist.find(params[:id])
      artist_streams = @artist.plays.where(stream: stream)

      @song_ratings = {}
      @songs = []
      @artist.songs.each do |song|
        chooser = stream.choosers.where(song: song)
        if chooser.exists?
          @song_ratings[song.id] = chooser.pluck(:rating).first
          @songs << song
        end
      end
      @play_count = artist_streams.count
      @last_played_at = artist_streams.first.try(:playtime)
      @previous_played_at = artist_streams.second.try(:playtime)
      @rank = @artist.stream_rank(stream)
      @last_week_rank = @artist.stream_rank(stream, 1.week.ago)
    end
  end
end

