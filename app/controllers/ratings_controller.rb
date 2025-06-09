class RatingsController < ApplicationController
  # POST /ratings.json
  def create
    @stream = Stream.find(params[:stream_id])
    @rating = Rating.new(rating_params.merge(user: current_user))
    chooser = @stream.choosers.where(song: @rating.play.song).first
    @old_rating = chooser.rating

    if @rating.save
      @new_rating = chooser.reload.rating
      @can_rate_again = current_user == @stream.user
      render :show, status: :created, location: stream_ratings_path(@stream, @rating)
    else
      render json: @rating.errors, status: :unprocessable_entity
    end
  end

  private
    def rating_params
      params.require(:rating).permit(:up, :play_id)
    end
end
