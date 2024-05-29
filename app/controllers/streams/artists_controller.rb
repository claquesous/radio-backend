module Streams
  class ArtistsController < ApplicationController
    # GET /streams/1/artists/1.json
    def show
      stream = Stream.find(params[:stream_id])
      artist = Artist.find(params[:id])
      artist_streams = stream.plays.where(artist_id: artist.id)

      @play_count = artist_streams.count
      @last_played_at = artist_streams.first.try(:playtime)
      @previous_played_at = artist_streams.second.try(:playtime)
      @rank = artist.stream_rank(stream)
      @last_week_rank = artist.stream_rank(stream, 1.week.ago)
    end
  end
end

