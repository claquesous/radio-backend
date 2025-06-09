class AuthsController < ApplicationController
  skip_before_action :authenticate_request, only: [:create, :destroy]

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
      render json: { token: token, user: user.as_json(only: [:id, :email, :admin]) }, status: :ok
    else
      render json: { error: "Email or password was invalid" }, status: :unauthorized
    end
  end

  # DELETE /api/logout
  def destroy
    cookies.delete(:jwt, httponly: true, secure: Rails.env.production?, same_site: :lax)
    head :no_content
  end

  # GET /private/auth (JWT session check for nginx)
  def show
    head @current_user ? :ok : :unauthorized
  end

  private

  def jwt_token
    cookies[:jwt]
  end
end
