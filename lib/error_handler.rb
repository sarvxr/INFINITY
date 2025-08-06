module ErrorHandler
  class ValidationError < StandardError; end
  class AuthenticationError < StandardError; end
  class FacebookAPIError < StandardError; end
  class DatabaseError < StandardError; end

  def self.handle_validation_error(error)
    {
      error: 'Validation failed',
      details: error.message,
      status: 400
    }
  end

  def self.handle_authentication_error(error)
    {
      error: 'Authentication failed',
      details: error.message,
      status: 401
    }
  end

  def self.handle_facebook_api_error(error)
    {
      error: 'Facebook API error',
      details: error.message,
      status: 400
    }
  end

  def self.handle_database_error(error)
    {
      error: 'Database error',
      details: 'An internal error occurred',
      status: 500
    }
  end

  def self.handle_generic_error(error)
    {
      error: 'Internal server error',
      details: 'Something went wrong',
      status: 500
    }
  end

  def self.log_error(error, context = {})
    logger = Logger.new(STDOUT)
    logger.error "Error in #{context[:method] || 'unknown'}: #{error.message}"
    logger.error "Backtrace: #{error.backtrace.first(5).join("\n")}" if error.backtrace
    logger.error "Context: #{context}" unless context.empty?
  end

  def self.validate_email(email)
    return false unless email.is_a?(String)
    email.match?(URI::MailTo::EMAIL_REGEXP)
  end

  def self.validate_password(password)
    return false unless password.is_a?(String)
    password.length >= 6
  end

  def self.validate_username(username)
    return false unless username.is_a?(String)
    username.length >= 3 && username.length <= 30 && username.match?(/^[a-zA-Z0-9_]+$/)
  end

  def self.sanitize_input(input)
    return nil unless input.is_a?(String)
    input.strip.gsub(/[<>]/, '')
  end
end 