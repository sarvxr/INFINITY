require 'net/http'
require 'uri'

module HealthCheck
  class << self
    def ping_self
      return unless ENV['RENDER_EXTERNAL_URL']
      
      begin
        uri = URI(ENV['RENDER_EXTERNAL_URL'])
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = (uri.scheme == 'https')
        http.read_timeout = 10
        
        response = http.get('/health')
        puts "Health check successful: #{response.code}"
      rescue => e
        puts "Health check failed: #{e.message}"
      end
    end
    
    def start_monitoring
      return unless ENV['RACK_ENV'] == 'production'
      
      Thread.new do
        loop do
          ping_self
          sleep(600) # Ping every 10 minutes to prevent sleep
        end
      end
    end
  end
end
