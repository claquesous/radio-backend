class AlbumsController < ApplicationController
  skip_before_action :authenticate_request, only: [:index, :show]

  before_action :set_album, only: [:show, :update]

  # GET /albums.json
  def index
    if params[:query]
      @albums = Album.where("title ilike ?", "%#{params[:query]}%")
    else
      @albums = Album.all
    end
    render :index
  end

  # GET /albums/1.json
  def show
    render :show
  end

  # POST /albums.json
  def create
    @album = Album.new(album_params)
    authorize @album

    if @album.save
      render :show, status: :created, location: @album
    else
      render json: @album.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /albums/1.json
  def update
    authorize @album
    if @album.update(album_params)
      render :show, status: :ok, location: @album
    else
      render json: @album.errors, status: :unprocessable_entity
    end
  end

  private
    def set_album
      @album = Album.includes(:songs).find(params[:id])
    end

    def album_params
      params.require(:album).permit(:artist_id, :title, :sort, :slug, :tracks, :id3_genre, :record_label)
    end
end
