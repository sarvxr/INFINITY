module Security
  class InputValidator
    class << self
      def validate_email(email)
        return false unless email.is_a?(String) && !email.empty?
        email.match?(URI::MailTo::EMAIL_REGEXP)
      end

      def validate_password(password)
        return false unless password.is_a?(String)
        password.length >= 6 && password.length <= 128
      end

      def validate_username(username)
        return false unless username.is_a?(String)
        username.length >= 3 && username.length <= 30 && username.match?(/^[a-zA-Z0-9_]+$/)
      end

      def validate_facebook_id(id)
        return false unless id.is_a?(String)
        id.match?(/^\d+$/) && id.length >= 10
      end

      def sanitize_string(input)
        return nil unless input.is_a?(String)
        input.strip.gsub(/[<>\"'&]/, '')
      end

      def sanitize_html(input)
        return nil unless input.is_a?(String)
        input.gsub(/<[^>]*>/, '')
      end

      def validate_json_schema(data, schema)
        schema.each do |key, rules|
          value = data[key]
          
          if rules[:required] && (value.nil? || value.to_s.empty?)
            return false, "Missing required field: #{key}"
          end
          
          next if value.nil?
          
          if rules[:type] && !value.is_a?(rules[:type])
            return false, "Invalid type for #{key}: expected #{rules[:type]}"
          end
          
          if rules[:min_length] && value.to_s.length < rules[:min_length]
            return false, "#{key} too short: minimum #{rules[:min_length]} characters"
          end
          
          if rules[:max_length] && value.to_s.length > rules[:max_length]
            return false, "#{key} too long: maximum #{rules[:max_length]} characters"
          end
          
          if rules[:pattern] && !value.to_s.match?(rules[:pattern])
            return false, "#{key} format invalid"
          end
        end
        
        [true, nil]
      end
    end
  end

  class RateLimiter
    def initialize(redis_client = nil)
      @redis = redis_client || Redis.new
    end

    def check_rate_limit(key, max_requests, window_seconds)
      current_time = Time.now.to_i
      window_start = current_time - window_seconds
      
      # Remove old entries
      @redis.zremrangebyscore(key, 0, window_start)
      
      # Count current requests
      current_requests = @redis.zcard(key)
      
      if current_requests >= max_requests
        return false, "Rate limit exceeded"
      end
      
      # Add current request
      @redis.zadd(key, current_time, "#{current_time}-#{SecureRandom.hex(8)}")
      @redis.expire(key, window_seconds)
      
      [true, nil]
    rescue => e
      # If Redis is not available, allow the request
      [true, nil]
    end
  end

  class TokenManager
    class << self
      def generate_token(payload, secret = nil)
        secret ||= ENV['JWT_SECRET'] || 'your-secret-key'
        JWT.encode(payload, secret, 'HS256')
      end

      def decode_token(token, secret = nil)
        secret ||= ENV['JWT_SECRET'] || 'your-secret-key'
        JWT.decode(token, secret, true, { algorithm: 'HS256' })
      rescue JWT::DecodeError => e
        [nil, e.message]
      end

      def refresh_token(token, secret = nil)
        decoded, error = decode_token(token, secret)
        return [nil, error] if error
        
        # Generate new token with extended expiry
        payload = decoded[0]
        payload['exp'] = 24.hours.from_now.to_i
        
        [generate_token(payload, secret), nil]
      end
    end
  end

  class PasswordManager
    class << self
      def hash_password(password)
        BCrypt::Password.create(password, cost: 12)
      end

      def verify_password(password, hash)
        BCrypt::Password.new(hash) == password
      rescue BCrypt::Errors::InvalidHash
        false
      end

      def generate_secure_password(length = 12)
        SecureRandom.alphanumeric(length)
      end
    end
  end

  class CSRFProtection
    class << self
      def generate_token
        SecureRandom.hex(32)
      end

      def verify_token(token, stored_token)
        return false if token.nil? || stored_token.nil?
        token == stored_token
      end
    end
  end

  class XSSProtection
    class << self
      def escape_html(input)
        return '' if input.nil?
        input.to_s
          .gsub('&', '&amp;')
          .gsub('<', '&lt;')
          .gsub('>', '&gt;')
          .gsub('"', '&quot;')
          .gsub("'", '&#x27;')
      end

      def sanitize_url(url)
        return nil if url.nil?
        uri = URI.parse(url)
        return nil unless ['http', 'https'].include?(uri.scheme)
        url
      rescue URI::InvalidURIError
        nil
      end
    end
  end
end 