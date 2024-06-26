class ArtistsController < ApplicationController
  before_action :set_artist, only: [:show, :edit, :update]

  # GET /artists
  # GET /artists.json
  def index
    if params[:query]
      @artists = Artist.where("name ilike ?", "%#{params[:query]}%")
    else
      @artists = Artist.all
    end
  end

  # GET /artists/1
  # GET /artists/1.json
  def show
  end

  # GET /artists/new
  def new
    @artist = Artist.new
    authorize @artist
  end

  # GET /artists/1/edit
  def edit
    authorize @artist
  end

  # POST /artists
  # POST /artists.json
  def create
    @artist = Artist.new(artist_params)
    authorize @artist

    respond_to do |format|
      if @artist.save
        format.html { redirect_to @artist, notice: 'Artist was successfully created.' }
        format.json { render :show, status: :created, location: @artist }
      else
        format.html { render :new }
        format.json { render json: @artist.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /artists/1
  # PATCH/PUT /artists/1.json
  def update
    authorize @artist
    respond_to do |format|
      if @artist.update(artist_params)
        format.html { redirect_to @artist, notice: 'Artist was successfully updated.' }
        format.json { render :show, status: :ok, location: @artist }
      else
        format.html { render :edit }
        format.json { render json: @artist.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_artist
      @artist = Artist.includes(:songs).find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def artist_params
      params.require(:artist).permit(:name, :sort, :slug)
    end
end
