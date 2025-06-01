module ExceptionHandler
  extend ActiveSupport::Concern

  class InvalidToken < StandardError; end
  class MissingToken < StandardError; end
  class ExpiredSignature < StandardError; end
  class DecodeError < StandardError; end

  included do
    rescue_from ActiveRecord::RecordNotFound do |e|
      render json: { message: e.message }, status: :not_found
    end

    rescue_from ExceptionHandler::MissingToken do |e|
      render json: { message: e.message }, status: :unprocessable_entity
    end

    rescue_from ExceptionHandler::InvalidToken do |e|
      render json: { message: e.message }, status: :unprocessable_entity
    end

    rescue_from ExceptionHandler::ExpiredSignature do |e|
      render json: { message: e.message }, status: :unprocessable_entity
    end

    rescue_from JWT::DecodeError do |e|
      render json: { message: e.message }, status: :unprocessable_entity
    end
  end
end
