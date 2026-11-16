class PlaysController < ApplicationController
  skip_before_action :authenticate_request
  before_action :set_stream

  # GET /plays.json
  def index
    limit = (params[:limit] || 25).to_i
    @plays = @stream.plays.includes(:artist, :song, :album).limit(limit)

    @song_ratings = {}
    @plays.each do |play|
      @song_ratings[play.song.id] = @stream.choosers.where(song: play.song).pluck(:rating).first
    end
    render :index
  end

  # GET /plays/1.json
  def show
    @play = Play.find(params[:id])
    render :show
  end

  # POST /plays.json
  def create
    @play = @stream.next_play

    if @play.save
      render :create, status: :created, location: @play
    else
      render json: @play.errors, status: :unprocessable_entity
    end
  end

  # GET /private/streams/:stream_id/plays/current
  # Read-only: the play on the air now and how far into its song it is, so an
  # encoder that restarts mid-song resumes it instead of recording a new Play.
  def current
    @play = @stream.current_play

    if @play
      render :current
    else
      head :not_found
    end
  end

  private

    def set_stream
      @stream = Stream.find(params[:stream_id] || 1)
    end
end
