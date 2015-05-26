class PlaysController < ApplicationController
  before_action :set_play, only: [:show, :edit, :update]
  skip_before_filter :verify_authenticity_token, only: :create

  # GET /plays
  # GET /plays.json
  def index
    @plays = Play.limit(25)
  end

  # GET /plays/1
  # GET /plays/1.json
  def show
  end

  # GET /plays/new
  def new
    @play = Play.new
  end

  # GET /plays/1/edit
  def edit
  end

  # POST /plays
  # POST /plays.json
  def create
    @play = Play.next

    respond_to do |format|
      if @play.save
        format.html { redirect_to @play, notice: 'Play was successfully created.' }
        format.json { render :show, status: :created, location: @play }
      else
        format.html { render :new }
        format.json { render json: @play.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /plays/1
  # PATCH/PUT /plays/1.json
  def update
    respond_to do |format|
      if @play.update(play_params)
        format.html { redirect_to @play, notice: 'Play was successfully updated.' }
        format.json { render :show, status: :ok, location: @play }
      else
        format.html { render :edit }
        format.json { render json: @play.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_play
      @play = Play.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def play_params
      params.require(:play).permit(:song, :ratings)
    end
end
