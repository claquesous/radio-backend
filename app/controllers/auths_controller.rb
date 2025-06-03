class AuthsController < ApplicationController
  include Authenticable
  skip_before_action :authenticate_request, only: [:create]
  skip_before_action :require_login, only: [:create]
  skip_before_action :verify_authenticity_token, only: [:create]

  def create
    user = login(params[:email], params[:password])
    if user
      payload = { user_id: user.id, exp: 24.hours.from_now.to_i }
      token = JWT.encode(payload, Rails.application.secret_key_base, 'HS256')
      render json: { token: token, user: user.as_json(only: [:id, :email, :admin]) }, status: :ok
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end
end
