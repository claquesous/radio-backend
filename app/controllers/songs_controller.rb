require 'mp3info'

class SongsController < ApplicationController
  before_action :set_song, only: [:show, :edit, :update]

  # GET /songs
  # GET /songs.json
  def index
    limit = (params[:limit] || 25).to_i
    if params[:artist]
      @songs = Artist.find(params[:artist]).songs.limit(limit)
    elsif params[:album]
      @songs = Album.find(params[:album]).songs.limit(limit)
    elsif params[:query]
      @songs = Song.where("title ilike ?", "%#{params[:query]}%").limit(limit)
    else
      @songs = Song.limit(limit)
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
  def create
    uploaded_file = params[:song][:file]
    mp3_info = Mp3Info.new(uploaded_file.tempfile.path)

    artist_name = mp3_info.tag.artist
    artist = Artist.find_or_initialize_by(name: artist_name)

    if artist.new_record?
      # Artist doesn't exist, prompt the user to create a new one
      render :new_artist, locals: { artist: artist }, notice: "Artist does not exist!"
    else
      # Artist exists, create the song and associate it with the artist
      @song = artist.songs.build
      @song.from_mp3_info(mp3_info)
      upload_to_s3(uploaded_file)

      if @song.save
        redirect_to @song, notice: 'Song was successfully created.'
      else
        render :new
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

    def upload_to_s3(file)
      s3 = Aws::S3::Resource.new(region: ENV['AWS_REGION'])
      obj = s3.bucket(ENV['AWS_S3_BUCKET']).object(@song.s3_path)

      obj.upload_file(file.tempfile.path)
    end
end
