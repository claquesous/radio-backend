class RequestsController < ApplicationController
  # GET /requests.json
  def index
    @requests = Request.all.includes(:song)
    render :index
  end

  # GET /requests/1.json
  def show
    @request = Request.find(params[:id])
    render :show
  end

  # POST /requests.json
  def create
    @stream = Stream.find(params[:stream_id])
    @request = @stream.requests.build(request_params.merge(user: current_user, requested_at: Time.now, played: false))

    if @request.save
      render :show, status: :created, location: stream_request_path(@stream, @request)
    else
      render json: @request.errors, status: :unprocessable_entity
    end
  end

  private
    def request_params
      params.require(:request).permit(:song_id)
    end
end
