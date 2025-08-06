#!/usr/bin/env ruby

require 'bundler/setup'
require 'sinatra/activerecord'

# Determine environment
env = ENV['RACK_ENV'] || 'development'

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

# Create database directory if it doesn't exist (for development)
if env == 'development'
  Dir.mkdir('db') unless Dir.exist?('db')
end

# Create tables
puts "Creating database tables..."

# Create users table
ActiveRecord::Base.connection.create_table :users, force: true do |t|
  t.string :email, null: false
  t.string :username, null: false
  t.string :password_hash, null: false
  t.timestamps
end

# Create facebook_accounts table
ActiveRecord::Base.connection.create_table :facebook_accounts, force: true do |t|
  t.references :user, null: false, foreign_key: true
  t.string :email, null: false
  t.text :access_token, null: false
  t.string :status, default: 'active'
  t.integer :followers_count, default: 0
  t.integer :following_count, default: 0
  t.integer :likes_count, default: 0
  t.string :safety_level, default: 'balanced'
  t.datetime :paused_until
  t.integer :daily_action_limit, default: 100
  t.integer :hourly_action_limit, default: 10
  t.integer :consecutive_failures, default: 0
  t.datetime :last_action_at
  t.datetime :last_break_at
  t.integer :total_actions_today, default: 0
  t.integer :total_actions_this_hour, default: 0
  t.decimal :risk_factor, precision: 5, scale: 2, default: 0.0
  t.boolean :safety_paused, default: false
  t.text :safety_warnings
  t.integer :account_age_days, default: 0
  t.decimal :safety_score, precision: 5, scale: 2, default: 100.0
  t.timestamps
end

# Create follower_logs table
ActiveRecord::Base.connection.create_table :follower_logs, force: true do |t|
  t.references :facebook_account, null: false, foreign_key: true
  t.string :action, null: false
  t.string :target, null: false
  t.boolean :success, default: false
  t.text :response_data
  t.timestamps
end

# Add indexes
ActiveRecord::Base.connection.add_index :users, :email, unique: true
ActiveRecord::Base.connection.add_index :users, :username, unique: true
ActiveRecord::Base.connection.add_index :facebook_accounts, :email
ActiveRecord::Base.connection.add_index :facebook_accounts, :status
ActiveRecord::Base.connection.add_index :facebook_accounts, :safety_level
ActiveRecord::Base.connection.add_index :facebook_accounts, :safety_paused
ActiveRecord::Base.connection.add_index :facebook_accounts, :risk_factor
ActiveRecord::Base.connection.add_index :facebook_accounts, :safety_score
ActiveRecord::Base.connection.add_index :follower_logs, :action
ActiveRecord::Base.connection.add_index :follower_logs, :success
ActiveRecord::Base.connection.add_index :follower_logs, :created_at

puts "Database setup completed successfully!"
puts "Tables created: users, facebook_accounts, follower_logs"
puts "Environment: #{env}" 