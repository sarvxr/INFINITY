#!/usr/bin/env ruby

require 'bundler/setup'
require 'sinatra/activerecord'

# Determine environment
env = ENV['RACK_ENV'] || 'development'

puts "Starting Infinity application..."
puts "Environment: #{env}"

# Set up database connection
if env == 'production'
  # Production: Use DATABASE_URL from environment
  ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
  puts "Connected to production database"
else
  # Development: Use SQLite
  require 'sqlite3'
  ActiveRecord::Base.establish_connection(
    adapter: 'sqlite3',
    database: 'db/development.sqlite3'
  )
  puts "Connected to development database"
end

# Run database setup
puts "Setting up database..."
load File.join(__dir__, 'db', 'setup.rb')

puts "Database setup completed!"
puts "Starting application..."

# Load the main application
require_relative 'app'

puts "Infinity application is ready!"
