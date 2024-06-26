class SessionsController < ApplicationController
  skip_before_action :require_login

  def create
    user = login(params[:email], params[:password], params[:remember_me])
    if user
      redirect_back_or_to root_url, :notice => "Logged in!"
    else
      flash.now.alert = "Email or password was invalid"
      render :new
    end
  end

  def destroy
    logout
    redirect_to root_url, :notice => "Logged out!"
  end

  def logged_in
    if current_user
      head :ok
    else
      head :unauthorized
    end
  end
end
