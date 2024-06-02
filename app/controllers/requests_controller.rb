class RequestsController < ApplicationController
  before_action :set_stream
  # GET /requests
  # GET /requests.json
  def index
    @requests = Request.all
  end

  # GET /requests/1
  # GET /requests/1.json
  def show
    @request = Request.find(params[:id])
  end

  private

    def set_stream
      @stream = Stream.find(params[:stream_id] || 1)
    end
end
