class StreamsController < ApplicationController
  skip_before_action :authenticate_request, only: [:index, :show]

  before_action :set_stream, only: %i[ show update destroy available_songs ]
  before_action :remove_blank_mastodon_access_token, only: :update

  # GET /streams.json
  def index
    @streams = policy_scope(Stream)
    render :index
  end

  # GET /streams/1.json
  def show
    render :show
  end

  # POST /streams.json
  def create
    @stream = Stream.new(stream_params)
    @stream.user = current_user
    if @stream.save
      render :show, status: :created, location: @stream
    else
      render json: @stream.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /streams/1.json
  def update
    authorize @stream
    if @stream.update(stream_params)
      render :show, status: :ok, location: @stream
    else
      render json: @stream.errors, status: :unprocessable_entity
    end
  end

  # DELETE /streams/1.json
  def destroy
    authorize @stream
    @stream.destroy!
    head :no_content
  end

  # GET /streams/1/available_songs.json
  def available_songs
    chosen_song_ids = @stream.choosers.pluck(:song_id)
    @songs = Song.where.not(id: chosen_song_ids).includes(:artist, :album)

    if params[:limit].present?
      limit_value = params[:limit].to_i
      @songs = @songs.limit(limit_value) if limit_value > 0
    end

    if params[:offset].present?
      offset_value = [params[:offset].to_i, 0].max
      @songs = @songs.offset(offset_value)
    end

    render 'songs/index'
  end

  private
    def set_stream
      @stream = Stream.find(params[:id])
    end

    def stream_params
      permitted = params.require(:stream).permit(
        :name,
        :default_rating,
        :default_featured,
        :mastodon_url,
        :mastodon_access_token,
        :premium,
        :genre,
        :description,
        :enabled
      )
      [:name, :genre, :description].each do |key|
        permitted[key] = ERB::Util.html_escape(permitted[key]) if permitted[key]
      end
      permitted
    end

    def remove_blank_mastodon_access_token
      params[:stream].delete(:mastodon_access_token) if params[:stream][:mastodon_access_token].blank?
    end
end
