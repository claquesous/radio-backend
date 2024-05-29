class ChoosersController < ApplicationController
  before_action :set_chooser, only: %i[ show edit update ]
  before_action :set_stream

  # GET /choosers or /choosers.json
  def index
    @choosers = @stream.choosers
  end

  # GET /choosers/1 or /choosers/1.json
  def show
  end

  # GET /choosers/1/edit
  def edit
  end

  # PATCH/PUT /choosers/1 or /choosers/1.json
  def update
    respond_to do |format|
      if @chooser.update(chooser_params)
        format.html { redirect_to stream_chooser_url(@stream, @chooser), notice: "Chooser was successfully updated." }
        format.json { render :show, status: :ok, location: @chooser }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @chooser.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_chooser
      @chooser = Chooser.find(params[:id])
    end

    def set_stream
      @stream = Stream.find(params[:stream_id])
    end

    # Only allow a list of trusted parameters through.
    def chooser_params
      params.require(:chooser).permit(:song_id, :stream_id, :featured, :rating)
    end
end
