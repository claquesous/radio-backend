class ListenersController < ApplicationController
  # GET /listeners
  # GET /listeners.json
  def index
    @listeners = Listener.all
  end

  # GET /listeners/1
  # GET /listeners/1.json
  def show
    @listener = Listener.find(params[:id])
  end
end
