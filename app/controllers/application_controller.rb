class ApplicationController < ActionController::Base
  include Authenticable

  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    head :unauthorized
  end
end
