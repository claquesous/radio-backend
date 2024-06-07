class StreamsController < ApplicationController
  before_action :set_stream, only: %i[ show edit update destroy ]
  before_action :remove_blank_mastodon_access_token, only: :update

  # GET /streams or /streams.json
  def index
    @streams = policy_scope(Stream)
  end

  # GET /streams/1 or /streams/1.json
  def show
    authorize @stream
  end

  # GET /streams/new
  def new
    @stream = Stream.new
  end

  # GET /streams/1/edit
  def edit
    authorize @stream
  end

  # POST /streams or /streams.json
  def create
    @stream = Stream.new(stream_params)

    respond_to do |format|
      if @stream.save
        format.html { redirect_to stream_url(@stream), notice: "Stream was successfully created." }
        format.json { render :show, status: :created, location: @stream }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @stream.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /streams/1 or /streams/1.json
  def update
    authorize @stream
    respond_to do |format|
      if @stream.update(stream_params)
        format.html { redirect_to stream_url(@stream), notice: "Stream was successfully updated." }
        format.json { render :show, status: :ok, location: @stream }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @stream.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /streams/1 or /streams/1.json
  def destroy
    authorize @stream
    @stream.destroy!

    respond_to do |format|
      format.html { redirect_to streams_url, notice: "Stream was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_stream
      @stream = Stream.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def stream_params
      params.require(:stream).permit(:name, :user_id, :default_rating, :default_featured, :mastodon_url, :mastodon_access_token)
    end

    def remove_blank_mastodon_access_token
      params[:stream].delete(:mastodon_access_token) if params[:stream][:mastodon_access_token].blank?
    end
end
