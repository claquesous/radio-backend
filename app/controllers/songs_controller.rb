class SongsController < ApplicationController
  include Mp3Attrs
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
    authorize @song
  end

  # GET /songs/1/edit
  def edit
    authorize @song
  end

  # POST /songs
  def create
    @artist = Artist.find_or_initialize_by(name: mp3_artist_name)

    if @artist.new_record?
      # Artist doesn't exist, prompt the user to create a new one
      @artist.sort = mp3_artist_sort
      render "artists/new", locals: { artist: @artist }, notice: "Artist does not exist!"
    else
      # Artist exists, create the song and associate it with the artist
      @song = @artist.songs.build
      authorize @song
      @song.assign_attributes mp3_song_attrs
      upload_to_s3

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
    authorize @song
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
      params.require(:song).permit(:album, :artist_id, :artist_name_override, :title, :sort, :slug, :track, :time, :featured, :live, :remix, :rating, :path)
    end

    def upload_to_s3
      s3 = Aws::S3::Resource.new(region: ENV['AWS_REGION'])
      obj = s3.bucket(ENV['AWS_S3_BUCKET']).object(s3_path)
      obj.upload_file(uploaded_file.tempfile.path)
    end

    def uploaded_file
      params[:song][:file]
    end
end
