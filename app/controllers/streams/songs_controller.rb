module Streams
  class SongsController < ApplicationController
    # GET /streams/1/songs/1.json
    def show
      stream = Stream.find(params[:stream_id])
      @song = Song.find(params[:id])
      song_streams = @song.plays.where(stream: stream)

      @rating = stream.choosers.where(song: @song).pluck(:rating).first
      @play_count = song_streams.count
      @last_played_at = song_streams.first.try(:playtime)
      @previous_played_at = song_streams.second.try(:playtime)
      @rank = @song.stream_rank(stream)
      @last_week_rank = @song.stream_rank(stream, 1.week.ago)
    end
  end
end

