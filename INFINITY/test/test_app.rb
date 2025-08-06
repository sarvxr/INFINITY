#!/usr/bin/env ruby

require 'minitest/autorun'
require 'rack/test'
require 'json'
require_relative '../app'

class InfinityServerTest < Minitest::Test
  include Rack::Test::Methods

  def app
    InfinityServer
  end

  def setup
    # Setup test database
    ActiveRecord::Base.establish_connection(
      adapter: 'sqlite3',
      database: ':memory:'
    )
    
    # Create tables
    ActiveRecord::Schema.define do
      create_table :users do |t|
        t.string :email, null: false
        t.string :username, null: false
        t.string :password_hash, null: false
        t.timestamps
      end
      
      create_table :facebook_accounts do |t|
        t.references :user, null: false
        t.string :email, null: false
        t.text :access_token, null: false
        t.string :status, default: 'active'
        t.integer :followers_count, default: 0
        t.integer :following_count, default: 0
        t.integer :likes_count, default: 0
        t.timestamps
      end
      
      create_table :follower_logs do |t|
        t.references :facebook_account, null: false
        t.string :action, null: false
        t.string :target, null: false
        t.boolean :success, default: false
        t.text :response_data
        t.timestamps
      end
    end
  end

  def test_homepage_returns_200
    get '/'
    assert_equal 200, last_response.status
  end

  def test_api_status_returns_200
    get '/api/status'
    assert_equal 200, last_response.status
    
    data = JSON.parse(last_response.body)
    assert_equal 'online', data['status']
    assert data['timestamp']
    assert_equal '1.0.0', data['version']
  end

  def test_register_with_valid_data
    post '/api/auth/register', {
      email: 'test@example.com',
      password: 'password123',
      username: 'testuser'
    }.to_json, 'CONTENT_TYPE' => 'application/json'
    
    assert_equal 200, last_response.status
    
    data = JSON.parse(last_response.body)
    assert data['token']
    assert_equal 'test@example.com', data['user']['email']
    assert_equal 'testuser', data['user']['username']
  end

  def test_register_with_invalid_data
    post '/api/auth/register', {
      email: 'invalid-email',
      password: '123',
      username: 'a'
    }.to_json, 'CONTENT_TYPE' => 'application/json'
    
    assert_equal 400, last_response.status
  end

  def test_login_with_valid_credentials
    # First register a user
    post '/api/auth/register', {
      email: 'test@example.com',
      password: 'password123',
      username: 'testuser'
    }.to_json, 'CONTENT_TYPE' => 'application/json'
    
    # Then login
    post '/api/auth/login', {
      email: 'test@example.com',
      password: 'password123'
    }.to_json, 'CONTENT_TYPE' => 'application/json'
    
    assert_equal 200, last_response.status
    
    data = JSON.parse(last_response.body)
    assert data['token']
  end

  def test_login_with_invalid_credentials
    post '/api/auth/login', {
      email: 'test@example.com',
      password: 'wrongpassword'
    }.to_json, 'CONTENT_TYPE' => 'application/json'
    
    assert_equal 401, last_response.status
  end

  def test_protected_routes_require_authentication
    get '/api/analytics'
    assert_equal 401, last_response.status
  end

  def test_404_for_unknown_routes
    get '/api/unknown'
    assert_equal 404, last_response.status
  end

  def test_invalid_json_returns_400
    post '/api/auth/register', 'invalid json', 'CONTENT_TYPE' => 'application/json'
    assert_equal 400, last_response.status
  end

  def teardown
    # Clean up
    ActiveRecord::Base.connection.close
  end
end

# Run tests if this file is executed directly
if __FILE__ == $0
  puts "Running Infinity Server tests..."
  Minitest::Test.run
end 