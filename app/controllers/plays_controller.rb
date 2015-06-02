class PlaysController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: :create

  # GET /plays
  # GET /plays.json
  def index
    limit = params[:limit] || 25
    @plays = Play.limit(limit.to_i)
  end

  # GET /plays/1
  # GET /plays/1.json
  def show
    @play = Play.find(params[:id])
  end

  # POST /plays
  # POST /plays.json
  def create
    @play = Play.next

    respond_to do |format|
      if @play.save
        format.html { redirect_to @play, notice: 'Play was successfully created.' }
        format.json { render :create, status: :created, location: @play }
      else
        format.html { render :new }
        format.json { render json: @play.errors, status: :unprocessable_entity }
      end
    end
  end
end
