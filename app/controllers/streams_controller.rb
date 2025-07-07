class StreamsController < ApplicationController
  skip_before_action :authenticate_request, only: [:index, :show]

  before_action :set_stream, except: %i[ index create ]
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

  # GET /streams/1/new_songs_with_included.json
  def new_songs_with_included
    limit = (params[:limit] || 25).to_i
    offset = (params[:offset] || 0).to_i
    songs = Song.order(created_at: :desc).limit(limit).offset(offset).includes(:artist, :album)
    chooser_ids = @stream.choosers.where(song_id: songs.map(&:id)).pluck(:song_id)
    result = songs.map do |song|
      {
        id: song.id,
        title: song.title,
        artist: { id: song.artist.id, name: song.artist.name },
        album: song.album ? { id: song.album.id, title: song.album.title } : nil,
        included: chooser_ids.include?(song.id)
      }
    end
    render json: result
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
