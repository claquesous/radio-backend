class ChoosersController < ApplicationController
  before_action :set_stream
  before_action :authorize_stream, except: [:index]

  # GET /choosers.json
  def index
    @choosers = @stream.choosers.includes(:song).includes(song: :artist)

    if params[:sort].present? && params[:sort] == 'created_at'
      @choosers = @choosers.unscoped.order(created_at: :desc)
    end

    total_count = nil
    limit_value = nil
    offset_value = nil

    if params[:limit].present?
      limit_value = params[:limit].to_i
      limit_value = nil if limit_value <= 0
    end

    if params[:offset].present?
      offset_value = [params[:offset].to_i, 0].max
    end

    if limit_value || offset_value
      total_count = @choosers.count

      @choosers = @choosers.limit(limit_value) if limit_value
      @choosers = @choosers.offset(offset_value) if offset_value

      if limit_value || offset_value
        @pagination = {
          total_count: total_count
        }
        @pagination[:limit] = limit_value if limit_value
        @pagination[:offset] = offset_value if offset_value
        @pagination[:total_pages] = (total_count.to_f / limit_value).ceil if limit_value
      end
    end

    render :index
  end

  # POST /choosers.json
  def create
    @chooser = @stream.choosers.build(chooser_params)
    if @chooser.save
      render :show, status: :created
    else
      render json: @chooser.errors, status: :unprocessable_entity
    end
  end

  # DELETE /choosers/1.json
  def destroy
    @chooser = @stream.choosers.find(params[:id])
    if @chooser.destroy
      head :no_content
    else
      render json: { errors: @chooser.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /choosers/1.json
  def update
    @chooser = Chooser.find(params[:id])
    if @chooser.update(chooser_params)
      render :show, status: :ok
    else
      render json: @chooser.errors, status: :unprocessable_entity
    end
  end

  private
    def set_stream
      @stream = Stream.find(params[:stream_id])
    end

    def authorize_stream
      authorize @stream, :update?
    end

    def chooser_params
      params.require(:chooser).permit(:song_id, :rating)
    end
end
