class AuthorizeApiRequest
  attr_reader :headers, :errors

  def initialize(headers = {})
    @headers = headers
    @errors = ActiveModel::Errors.new(self)
  end

  def self.call(headers = {})
    command = new(headers)
    result = command.call_instance
    OpenStruct.new(success?: command.errors.empty?, failure?: !command.errors.empty?, result: result, errors: command.errors)
  end

  def call_instance
    user
  end

  private

  def user
    @user ||= User.find(decoded_auth_token[:user_id]) if decoded_auth_token
    @user || errors.add(:token, 'Invalid token') && nil
  end

  def decoded_auth_token
    @decoded_auth_token ||= decode_token(http_auth_header)
  rescue JWT::DecodeError => e
    errors.add(:token, e.message)
    nil
  end

  def decode_token(token)
    body = JWT.decode(token, Rails.application.credentials.secret_key_base)[0]
    HashWithIndifferentAccess.new body
  end

  def http_auth_header
    if headers['Authorization'].present?
      return headers['Authorization'].split(' ').last
    end
    errors.add(:token, 'Missing token')
    nil
  end
end
