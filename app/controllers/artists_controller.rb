class ArtistsController < ApplicationController
  skip_before_action :authenticate_request, only: [:index, :show]

  before_action :set_artist, only: [:show, :update]

  # GET /artists.json
  def index
    if params[:query]
      @artists = Artist.where("name ilike ?", "%#{params[:query]}%")
    else
      @artists = Artist.all
    end
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

  private
    def set_artist
      @artist = Artist.includes(:songs).find(params[:id])
    end

    def artist_params
      params.require(:artist).permit(:name, :sort, :slug)
    end
end
