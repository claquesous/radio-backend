class RatingsController < ApplicationController
  # GET /ratings
  # GET /ratings.json
  def index
    @ratings = Rating.all
  end

  # GET /ratings/1
  # GET /ratings/1.json
  def show
    @rating = Rating.find(params[:id])
  end
 
  # POST /ratings
  # POST /ratings.json
  def create
    @play = Play.find(params[:play_id])
    @play.build_rating(rating_params.merge(user: user))

    respond_to do |format|
      if @play.save
        format.html { redirect_to @play, notice: 'Rating was successfully added.' }
        format.json { render :create, status: :created, location: @play }
      else
        format.html { render :new }
        format.json { render json: @play.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    def rating_params
      params.require(:rating).permit(:up)
    end
end
