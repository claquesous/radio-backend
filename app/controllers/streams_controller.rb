class StreamsController < ApplicationController
  include SimilarSongs
  MAX_SEEDS = 20
  MAX_RANDOM = 100

  skip_before_action :authenticate_request, only: [:index, :show, :enabled]

  before_action :set_stream, except: %i[ index create enabled ]
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

  # GET /private/streams.json
  # Called by the stream manager to reconcile which streams should be
  # running against what's actually enabled in Postgres, so a stream
  # doesn't stay silently stopped if DynamoDB/SQS state is lost or a
  # crash-retry budget is exhausted.
  def enabled
    @streams = Stream.where(enabled: true)
    render :enabled
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

  # GET /streams/1/available_songs.json?query=beatles+help&sort=newest
  # Songs not yet in the stream. Every word of query must match the title, artist
  # or album; sort=newest lists the most recently added songs first.
  def available_songs
    base = Song.where.not(id: @stream.choosers.unscope(:order).select(:song_id)).includes(:artist, :album)
    params[:query].to_s.split.each do |term|
      pattern = "%#{Song.sanitize_sql_like(term)}%"
      base = base.where(id: Song.unscoped.left_joins(:album).joins(:artist)
        .where("songs.title ILIKE :p OR artists.name ILIKE :p OR albums.title ILIKE :p", p: pattern).select(:id))
    end
    base = base.reorder(created_at: :desc, id: :desc) if params[:sort] == "newest"

    limit = (params[:limit] || 50).to_i
    offset = (params[:offset] || 0).to_i

    @songs = base.limit(limit).offset(offset)
    @pagination = { total: base.count }

    render 'songs/index'
  end

  # POST /streams/1/recommendations.json { seed_ids: [1, 2], exclude_ids: [3] }
  # Songs not yet in the stream that suit all the seeds, for building the playlist.
  # Without seed_ids, the seeds are a fresh random sample of the stream's own songs,
  # so repeated calls wander around the whole playlist.
  # exclude_ids lets a client page through fresh suggestions ("more"). It grows with
  # every page shown, which is why this is a POST: as a query string it outgrows
  # Puma's 10KB limit after a few dozen pages.
  def recommendations
    authorize @stream, :update?

    @seeds = if params[:seed_ids].present?
      Song.unscoped.where(id: Array(params[:seed_ids]).first(MAX_SEEDS))
    else
      @stream.songs.unscope(:order).joins(:song_feature).where.not(song_features: { sound_embedding: nil })
        .order(Arel.sql("RANDOM()")).limit(MAX_SEEDS)
    end.includes(:song_feature)
    @results = Recommender.similar(@seeds.to_a, **similar_options(default_limit: 8),
                                   excluding_stream: @stream, exclude_ids:)
  end

  # POST /streams/1/random_songs.json { limit: 20, exclude_ids: [3] }
  # A random sample of songs not yet in the stream, at most one per artist, for the
  # owner to pick from. Nothing is added; exclude_ids skips songs already shown.
  # With count, adds that many random songs instead, as the pre-picker frontend expects.
  def random_songs
    authorize @stream, :update?
    return add_random_songs if params.key?(:count)

    limit = (params[:limit] || 20).to_i.clamp(1, MAX_RANDOM)
    pool = Song.unscoped.where.not(id: @stream.choosers.unscope(:order).select(:song_id)).where.not(id: exclude_ids)
    one_per_artist = pool.select("DISTINCT ON (songs.artist_id) songs.id").order(Arel.sql("songs.artist_id, RANDOM()"))
    @songs = Song.unscoped.where(id: one_per_artist).order(Arel.sql("RANDOM()")).limit(limit)
      .includes(:artist, :album, :song_feature)
  end

  # GET /streams/1/new_songs.json
  def new_songs
    limit = (params[:limit] || 25).to_i
    offset = (params[:offset] || 0).to_i
    songs = Song.unscoped.order(created_at: :desc).limit(limit).offset(offset).includes(:artist, :album)
    choosers = @stream.choosers.where(song_id: songs.map(&:id))
    chooser_map = choosers.index_by(&:song_id)
    result = songs.map do |song|
      chooser = chooser_map[song.id]
      {
        id: song.id,
        title: song.title,
        artist: { id: song.artist.id, name: song.artist.name },
        included: !!chooser,
        chooser_id: chooser&.id
      }
    end
    render json: result
  end

  private
    # POST /streams/1/random_songs.json { count: 50 }
    # TODO: remove once the frontend's song picker has shipped.
    def add_random_songs
      count = params[:count].to_i.clamp(1, 500)
      available = Song.where.not(id: @stream.choosers.unscope(:order).select(:song_id))
        .reorder(Arel.sql("RANDOM()")).limit(count)
      rating = @stream.default_rating || 50
      added = available.to_a.count { |song| @stream.choosers.build(song:, rating:).save }
      render json: { added:, total: @stream.choosers.count }
    end

    def exclude_ids
      Array(params[:exclude_ids]).map(&:to_i)
    end

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
