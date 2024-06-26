class RequestsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create

  # GET /requests
  # GET /requests.json
  def index
    @requests = Request.all.includes(:song)
  end

  # GET /requests/1
  # GET /requests/1.json
  def show
    @request = Request.find(params[:id])
  end

  # POST /requests
  # POST /requests.json
  def create
    @stream = Stream.find(params[:stream_id])
    @request = @stream.requests.build(request_params.merge(user: current_user, requested_at: Time.now, played: false))

    respond_to do |format|
      if @request.save
        format.html { redirect_to stream_plays_path(@stream), notice: 'Request was successfully added.' }
        format.json { render :show, status: :created, location: stream_request_path(@stream, @request) }
      else
        format.html { redirect_to stream_plays_path(@stream), notice: "Request not added: #{@request.errors.full_messages.join(", ")}" }
        format.json { render json: @request.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    def request_params
      params.require(:request).permit(:song_id)
    end
end
