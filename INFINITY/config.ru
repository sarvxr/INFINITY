require 'bundler/setup'
require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/json'
require 'sinatra/cross_origin'
require 'rack/protection'
require 'dotenv/load'

# Load application files
require_relative 'app'
require_relative 'models/user'
require_relative 'models/facebook_account'
require_relative 'models/follower_log'
require_relative 'workers/follower_worker'

# Configure Sinatra
set :environment, ENV['RACK_ENV'] || 'development'
set :port, ENV['PORT'] || 4567
set :bind, '0.0.0.0'

# Enable CORS
configure do
  enable :cross_origin
  enable :sessions
  set :session_secret, ENV['SESSION_SECRET'] || 'your-secret-key'
  
  # Security headers
  set :protection, :except => [:json_csrf]
  set :protection, :origin_whitelist => ['http://localhost:3000', 'https://yourdomain.com']
end

# Database configuration
configure :development do
  set :database, { adapter: 'sqlite3', database: 'db/development.sqlite3' }
end

configure :production do
  set :database, ENV['DATABASE_URL']
end

# Run the application
run Sinatra::Application 