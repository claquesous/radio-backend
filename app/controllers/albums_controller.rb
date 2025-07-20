class AlbumsController < ApplicationController
  skip_before_action :authenticate_request, only: [:index, :show]

  before_action :set_album, only: [:show, :update, :destroy]

  # GET /albums.json
  def index
    limit = (params[:limit] || 25).to_i
    offset = (params[:offset] || 0).to_i

    if params[:query]
      base = Album.where("title ilike ?", "%#{params[:query]}%")
    else
      base = Album.all
    end

    @albums = base.limit(limit).offset(offset)
    @pagination = { total: base.count } if params[:limit].present? || params[:offset].present?

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

  # DELETE /albums/1.json
  def destroy
    authorize @album
    if @album.destroy
      head :no_content
    else
      render json: { errors: @album.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private
    def set_album
      @album = Album.includes(:songs).find(params[:id])
    end

    def album_params
      params.require(:album).permit(:title, :artist_id, :sort, :slug, :tracks, :id3_genre, :record_label, :musicbrainz_metadata)
    end
end
