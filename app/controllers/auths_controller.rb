class AuthsController < ApplicationController
  skip_before_action :authenticate_request, only: [:create]

  # POST /api/login (JWT authentication)
  def create
    user = login(params[:email], params[:password], params[:remember_me])
    if user
      token = JWT.encode({ user_id: user.id }, Rails.application.secret_key_base)
      # Set JWT as a secure, httpOnly cookie for auth#logged_in
      cookies[:jwt] = {
        value: token,
        httponly: true,
        secure: Rails.env.production?,
        same_site: :lax,
        expires: 1.day.from_now
      }
      render json: { token: token }, status: :created
    else
      render json: { error: "Email or password was invalid" }, status: :unauthorized
    end
  end

  # GET /private/auth (JWT session check for nginx)
  def logged_in
    @current_user = authenticate_with_jwt(cookies[:jwt])
    if @current_user
      head :ok
    else
      head :unauthorized
    end
  end
end
