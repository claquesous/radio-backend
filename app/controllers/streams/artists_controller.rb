module Streams
  class ArtistsController < ApplicationController
    # GET /streams/1/artists/1.json
    def show
      stream = Stream.find(params[:stream_id])
      @artist = Artist.find(params[:id])
      artist_streams = @artist.plays.where(stream: stream)

      @song_ratings = {}
      @artist.songs.each do |song|
        @song_ratings[song.id] = stream.choosers.where(song: song).pluck(:rating).first
      end
      @play_count = artist_streams.count
      @last_played_at = artist_streams.first.try(:playtime)
      @previous_played_at = artist_streams.second.try(:playtime)
      @rank = @artist.stream_rank(stream)
      @last_week_rank = @artist.stream_rank(stream, 1.week.ago)
    end
  end
end

