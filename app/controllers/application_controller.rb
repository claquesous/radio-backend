class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token

  include Authenticable

  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    head :unauthorized
  end
end
