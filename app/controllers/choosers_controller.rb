class ChoosersController < ApplicationController
  before_action :set_chooser, only: %i[ show edit update destroy ]

  # GET /choosers or /choosers.json
  def index
    @choosers = Chooser.all
  end

  # GET /choosers/1 or /choosers/1.json
  def show
  end

  # GET /choosers/new
  def new
    @chooser = Chooser.new
  end

  # GET /choosers/1/edit
  def edit
  end

  # POST /choosers or /choosers.json
  def create
    @chooser = Chooser.new(chooser_params)

    respond_to do |format|
      if @chooser.save
        format.html { redirect_to chooser_url(@chooser), notice: "Chooser was successfully created." }
        format.json { render :show, status: :created, location: @chooser }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @chooser.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /choosers/1 or /choosers/1.json
  def update
    respond_to do |format|
      if @chooser.update(chooser_params)
        format.html { redirect_to chooser_url(@chooser), notice: "Chooser was successfully updated." }
        format.json { render :show, status: :ok, location: @chooser }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @chooser.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /choosers/1 or /choosers/1.json
  def destroy
    @chooser.destroy!

    respond_to do |format|
      format.html { redirect_to choosers_url, notice: "Chooser was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_chooser
      @chooser = Chooser.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def chooser_params
      params.require(:chooser).permit(:song_id, :stream_id, :featured, :rating)
    end
end
