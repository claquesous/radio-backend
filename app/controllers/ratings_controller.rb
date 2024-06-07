class RatingsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create

  # POST /ratings
  # POST /ratings.json
  def create
    @stream = Stream.find(params[:stream_id])
    @rating = Rating.new(rating_params.merge(user: current_user))
    chooser = @stream.choosers.where(song: @rating.play.song).first
    @old_rating = chooser.rating

    respond_to do |format|
      if @rating.save
        @new_rating = chooser.reload.rating
        @can_rate_again = current_user == @stream.user
        format.html { redirect_to stream_plays_path(@stream), notice: 'Rating was successfully added.' }
        format.json { render :show, status: :created, location: stream_rating_path(@stream, @rating) }
      else
        format.html { redirect_to stream_plays_path(@stream), notice: "Rating not added: #{@rating.errors.full_messages.join(", ")}" }
        format.json { render json: @rating.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    def rating_params
      params.require(:rating).permit(:up, :play_id)
    end
end
