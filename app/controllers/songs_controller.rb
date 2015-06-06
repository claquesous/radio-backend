class SongsController < ApplicationController
  before_action :set_song, only: [:show, :edit, :update]

  # GET /songs
  # GET /songs.json
  def index
    limit = params[:limit] || 25
    if params[:artist]
      @songs = Artist.find(params[:artist]).songs.limit(limit.to_i)
    elsif params[:album]
      @songs = Album.find(params[:album]).songs.limit(limit.to_i)
    else
      @songs = Song.limit(limit.to_i)
    end
  end

  # GET /songs/1
  # GET /songs/1.json
  def show
  end

  # GET /songs/new
  def new
    @song = Song.new
  end

  # GET /songs/1/edit
  def edit
  end

  # POST /songs
  # POST /songs.json
  def create
    @song = Song.new(song_params)

    respond_to do |format|
      if @song.save
        format.html { redirect_to @song, notice: 'Song was successfully created.' }
        format.json { render :show, status: :created, location: @song }
      else
        format.html { render :new }
        format.json { render json: @song.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /songs/1
  # PATCH/PUT /songs/1.json
  def update
    respond_to do |format|
      if @song.update(song_params)
        format.html { redirect_to @song, notice: 'Song was successfully updated.' }
        format.json { render :show, status: :ok, location: @song }
      else
        format.html { render :edit }
        format.json { render json: @song.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_song
      @song = Song.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def song_params
      params.require(:song).permit(:album, :artist_id, :title, :sort, :slug, :track, :time, :featured, :live, :remix, :rating, :path)
    end
end
