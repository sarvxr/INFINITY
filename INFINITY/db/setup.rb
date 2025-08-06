#!/usr/bin/env ruby

require 'bundler/setup'
require 'sinatra/activerecord'
require 'sqlite3'

# Set up database connection
ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'db/development.sqlite3'
)

# Create database directory if it doesn't exist
Dir.mkdir('db') unless Dir.exist?('db')

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
ActiveRecord::Base.connection.add_index :follower_logs, :action
ActiveRecord::Base.connection.add_index :follower_logs, :success
ActiveRecord::Base.connection.add_index :follower_logs, :created_at

puts "Database setup completed successfully!"
puts "Tables created: users, facebook_accounts, follower_logs" 