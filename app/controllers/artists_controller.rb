class ArtistsController < ApplicationController
  skip_before_action :authenticate_request, only: [:index, :show]

  before_action :set_artist, only: [:show, :update, :destroy]

  # GET /artists.json
  def index
    limit = (params[:limit] || 25).to_i
    offset = (params[:offset] || 0).to_i

    if params[:query]
      base = Artist.where("name ilike ?", "%#{params[:query]}%")
    else
      base = Artist.all
    end

    @artists = base.limit(limit).offset(offset)
    @pagination = { total: base.count } if params[:limit].present? || params[:offset].present?

    render :index
  end

  # GET /artists/1.json
  def show
    render :show
  end

  # POST /artists.json
  def create
    @artist = Artist.new(artist_params)
    authorize @artist

    if @artist.save
      render :show, status: :created, location: @artist
    else
      render json: @artist.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /artists/1.json
  def update
    authorize @artist
    if @artist.update(artist_params)
      render :show, status: :ok, location: @artist
    else
      render json: @artist.errors, status: :unprocessable_entity
    end
  end

  # DELETE /artists/1.json
  def destroy
    authorize @artist
    if @artist.destroy
      head :no_content
    else
      render json: { errors: @artist.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private
    def set_artist
      @artist = Artist.includes(:songs).find(params[:id])
    end

    def artist_params
      params.require(:artist).permit(:name, :sort, :slug, musicbrainz_metadata: {})
    end
end
