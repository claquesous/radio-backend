class SongsController < ApplicationController
  skip_before_action :authenticate_request, only: [:index, :show]

  include Mp3Attrs

  before_action :set_song, only: [:show, :update]

  # GET /songs.json
  def index
    limit = (params[:limit] || 25).to_i
    offset = (params[:offset] || 0).to_i

    if params[:query]
      base = Song.where("title ilike ?", "%#{params[:query]}%")
    else
      base = Song.all
    end

    @songs = base.limit(limit).offset(offset)
    @pagination = { total: base.count } if params[:limit].present? || params[:offset].present?

    render :index
  end

  # GET /songs/1.json
  def show
    render :show
  end

  # POST /songs.json
  def create
    @artist = Artist.find_or_initialize_by(name: mp3_artist_name)

    if @artist.new_record?
      @artist.sort = mp3_artist_sort
      render json: { error: "Artist does not exist!", artist: @artist }, status: :unprocessable_entity
    else
      @song = @artist.songs.build
      authorize @song
      @song.assign_attributes mp3_song_attrs
      upload_to_s3

      if @song.save
        render :show, status: :created, location: @song
      else
        render json: @song.errors, status: :unprocessable_entity
      end
    end
  end

  # PATCH/PUT /songs/1.json
  def update
    authorize @song
    if @song.update(song_params)
      render :show, status: :ok, location: @song
    else
      render json: @song.errors, status: :unprocessable_entity
    end
  end

  private
    def set_song
      @song = Song.find(params[:id])
    end

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
