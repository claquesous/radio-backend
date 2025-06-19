class ChoosersController < ApplicationController
  skip_before_action :authenticate_request, only: [:index, :show]

  before_action :set_chooser, only: %i[ show update ]
  before_action :set_stream

  # GET /choosers.json
  def index
    @choosers = @stream.choosers.includes(:song)

    if params[:featured].present?
      featured_value = params[:featured] == 'true'
      @choosers = @choosers.where(featured: featured_value)
    end

    if params[:sort].present? && params[:sort] == 'created_at'
      @choosers = @choosers.order(created_at: :desc)
    end

    if params[:limit].present?
      limit_value = params[:limit].to_i
      @choosers = @choosers.limit(limit_value) if limit_value > 0
    end

    render :index
  end

  # GET /choosers/1.json
  def show
    render :show
  end

  # PATCH/PUT /choosers/1.json
  def update
    if @chooser.update(chooser_params)
      render :show, status: :ok, location: @chooser
    else
      render json: @chooser.errors, status: :unprocessable_entity
    end
  end

  private
    def set_chooser
      @chooser = Chooser.find(params[:id])
    end

    def set_stream
      @stream = Stream.find(params[:stream_id])
    end

    def chooser_params
      params.require(:chooser).permit(:featured, :rating)
    end
end
