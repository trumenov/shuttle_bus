class AuthorizeApiRequest
  prepend SimpleCommand

  def initialize(headers = {})
    @headers = headers
  end

  def call
    user
  end

  private

  attr_reader :headers

  def user
    unless @user
      if decoded_auth_token && decoded_auth_token.positive?
        @user = User.find(decoded_auth_token)
        errors.add(:token, 'Invalid token') unless @user
      end
    end
    @user
  end

  def decoded_auth_token
    @decoded_auth_token ||= JsonWebToken.decode(http_auth_header)
  end

  def http_auth_header
    if headers['XAuth'].present?
      return headers['XAuth'].split(' ').last
    else
      errors.add(:token, 'Missing token')
    end
    nil
  end
end
