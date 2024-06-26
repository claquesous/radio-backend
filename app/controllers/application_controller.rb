class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :require_login, if: proc { request.format.html? }

  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def not_authenticated
    redirect_to login_url, :alert => "First login to access this page."
  end

  private

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."

    redirect_to(request.referrer || root_path)
  end
end
