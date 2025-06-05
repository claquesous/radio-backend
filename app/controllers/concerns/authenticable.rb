module Authenticable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request
  end

  private

  def authenticate_request
    @current_user = authenticate_with_jwt(jwt_from_header)
    render json: { error: 'Not Authorized' }, status: 401 unless @current_user
  end

  def authenticate_with_jwt(token)
    return nil unless token
    begin
      decoded_token = decode_jwt(token)
      User.find(decoded_token[:user_id]) if decoded_token
    rescue JWT::DecodeError, ActiveRecord::RecordNotFound
      nil
    end
  end

  def jwt_from_header
    if request.headers['Authorization'].present?
      request.headers['Authorization'].split(' ').last
    else
      nil
    end
  end

  def decode_jwt(token)
    body = JWT.decode(token, Rails.application.secret_key_base)[0]
    HashWithIndifferentAccess.new body
  end
end
