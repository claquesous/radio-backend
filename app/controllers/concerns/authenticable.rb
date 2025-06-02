module Authenticable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request
  end

  private

  def authenticate_request
    @current_user = nil

    token = http_auth_header
    begin
      decoded_token = decode_token(token) if token
      @current_user = User.find(decoded_token[:user_id]) if decoded_token
    rescue JWT::DecodeError, ActiveRecord::RecordNotFound => e
      # Authentication failed, @current_user remains nil
    end

    render json: { error: 'Not Authorized' }, status: 401 unless @current_user
  end

  def http_auth_header
    request.headers['Authorization'].present? ? request.headers['Authorization'].split(' ').last : nil
  end

  def decode_token(token)
    body = JWT.decode(token, Rails.application.credentials.secret_key_base)[0]
    HashWithIndifferentAccess.new body
  end
end
