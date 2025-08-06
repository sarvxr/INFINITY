require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/json'
require 'sinatra/cross_origin'
require 'bcrypt'
require 'jwt'
require 'json'
require 'httparty'
require 'time'
require 'digest'
require 'erb'
require 'uri'
require 'open3'
require 'date'
require 'logger'
require 'sidekiq'
require 'redis'

# Load custom modules
require_relative 'lib/matematika'
require_relative 'lib/threadpool'
require_relative 'lib/files'
require_relative 'lib/os'
require_relative 'lib/error_handler'
require_relative 'lib/security'
require_relative 'lib/anti_detection'
require_relative 'lib/health_check'

# Load models
require_relative 'models/user'
require_relative 'models/facebook_account'
require_relative 'models/follower_log'

# Load workers
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

# Start health monitoring for Render free tier
HealthCheck.start_monitoring if ENV['RACK_ENV'] == 'production'

# Health check endpoint for Render
get '/health' do
  content_type :json
  { status: 'healthy', timestamp: Time.now.iso8601, environment: ENV['RACK_ENV'] }.to_json
end

# Before filters
before do
  content_type 'text/html; charset=utf-8'
end

# Authentication helper
def authenticate_user!
  token = request.env['HTTP_AUTHORIZATION']&.gsub('Bearer ', '')
  return halt 401, json({ error: 'No token provided' }) unless token
  
  begin
    decoded = JWT.decode(token, ENV['JWT_SECRET'] || 'your-secret-key', true, { algorithm: 'HS256' })
    @current_user = User.find(decoded[0]['user_id'])
  rescue JWT::DecodeError
    halt 401, json({ error: 'Invalid token' })
  rescue ActiveRecord::RecordNotFound
    halt 401, json({ error: 'User not found' })
  rescue => e
    logger.error "Authentication error: #{e.message}"
    halt 401, json({ error: 'Authentication failed' })
  end
end

# Routes
get '/' do
  erb :index
end

get '/dashboard' do
  authenticate_user!
  erb :dashboard
end

get '/api/status' do
  json({
    status: 'online',
    timestamp: Time.now.iso8601,
    version: '1.0.0',
    environment: settings.environment
  })
end

# Authentication routes
post '/api/auth/register' do
  begin
    data = JSON.parse(request.body.read)
    
    # Validate required fields
    unless data['email'] && data['password'] && data['username']
      return json({ error: 'Missing required fields' }), 400
    end
    
    if User.exists?(email: data['email'])
      return json({ error: 'Email already exists' }), 400
    end
    
    if User.exists?(username: data['username'])
      return json({ error: 'Username already exists' }), 400
    end
    
    user = User.create!(
      email: data['email'],
      password_hash: BCrypt::Password.create(data['password']),
      username: data['username']
    )
    
    token = JWT.encode({ user_id: user.id }, ENV['JWT_SECRET'] || 'your-secret-key', 'HS256')
    json({ token: token, user: { id: user.id, email: user.email, username: user.username } })
  rescue JSON::ParserError
    json({ error: 'Invalid JSON' }), 400
  rescue => e
    logger.error "Registration error: #{e.message}"
    json({ error: 'Registration failed' }), 500
  end
end

post '/api/auth/login' do
  begin
    data = JSON.parse(request.body.read)
    
    # Validate required fields
    unless data['email'] && data['password']
      return json({ error: 'Email and password required' }), 400
    end
    
    user = User.find_by(email: data['email'])
    
    if user && BCrypt::Password.new(user.password_hash) == data['password']
      token = JWT.encode({ user_id: user.id }, ENV['JWT_SECRET'] || 'your-secret-key', 'HS256')
      json({ token: token, user: { id: user.id, email: user.email, username: user.username } })
    else
      json({ error: 'Invalid credentials' }), 401
    end
  rescue JSON::ParserError
    json({ error: 'Invalid JSON' }), 400
  rescue => e
    logger.error "Login error: #{e.message}"
    json({ error: 'Login failed' }), 500
  end
end

# Facebook account management
post '/api/facebook/connect' do
  authenticate_user!
  begin
    data = JSON.parse(request.body.read)
    
    # Validate required fields
    unless data['email'] && data['password']
      return json({ error: 'Email and password required' }), 400
    end
    
    # Check if account already exists
    if @current_user.facebook_accounts.exists?(email: data['email'])
      return json({ error: 'Account already connected' }), 400
    end
    
    token = authenticate_facebook(data['email'], data['password'])
    
    account = FacebookAccount.create!(
      user: @current_user,
      email: data['email'],
      access_token: token,
      status: 'active'
    )
    
    json({ success: true, account_id: account.id })
  rescue JSON::ParserError
    json({ error: 'Invalid JSON' }), 400
  rescue => e
    logger.error "Facebook connect error: #{e.message}"
    json({ error: e.message }), 400
  end
end

get '/api/facebook/accounts' do
  authenticate_user!
  begin
    accounts = @current_user.facebook_accounts
    json(accounts.map { |acc| { 
      id: acc.id, 
      email: acc.email, 
      status: acc.status,
      followers_count: acc.followers_count || 0,
      following_count: acc.following_count || 0,
      likes_count: acc.likes_count || 0
    }})
  rescue => e
    logger.error "Get accounts error: #{e.message}"
    json({ error: 'Failed to fetch accounts' }), 500
  end
end

delete '/api/facebook/accounts/:id' do
  authenticate_user!
  begin
    account = @current_user.facebook_accounts.find(params[:id])
    account.destroy!
    json({ success: true, message: 'Account deleted successfully' })
  rescue ActiveRecord::RecordNotFound
    json({ error: 'Account not found' }), 404
  rescue => e
    logger.error "Delete account error: #{e.message}"
    json({ error: 'Failed to delete account' }), 500
  end
end

# Follower management
post '/api/followers/start' do
  authenticate_user!
  begin
    data = JSON.parse(request.body.read)
    
    unless data['account_id']
      return json({ error: 'Account ID required' }), 400
    end
    
    account = @current_user.facebook_accounts.find(data['account_id'])
    
    # Start background job
    FollowerWorker.perform_async(account.id, data['target_count'] || 10)
    
    json({ success: true, message: 'Follower process started' })
  rescue ActiveRecord::RecordNotFound
    json({ error: 'Account not found' }), 404
  rescue JSON::ParserError
    json({ error: 'Invalid JSON' }), 400
  rescue => e
    logger.error "Start automation error: #{e.message}"
    json({ error: 'Failed to start automation' }), 500
  end
end

post '/api/followers/stop' do
  authenticate_user!
  begin
    data = JSON.parse(request.body.read)
    
    unless data['account_id']
      return json({ error: 'Account ID required' }), 400
    end
    
    # Stop background job
    Sidekiq::Queue.new.each do |job|
      job.delete if job.args.first == data['account_id']
    end
    
    json({ success: true, message: 'Follower process stopped' })
  rescue JSON::ParserError
    json({ error: 'Invalid JSON' }), 400
  rescue => e
    logger.error "Stop automation error: #{e.message}"
    json({ error: 'Failed to stop automation' }), 500
  end
end

get '/api/followers/status/:account_id' do
  authenticate_user!
  begin
    account = @current_user.facebook_accounts.find(params[:account_id])
    
    logs = FollowerLog.where(facebook_account: account).order(created_at: :desc).limit(10)
    
    json({
      account_status: account.status,
      recent_logs: logs.map { |log| {
        action: log.action,
        target: log.target,
        success: log.success,
        created_at: log.created_at.iso8601
      }}
    })
  rescue ActiveRecord::RecordNotFound
    json({ error: 'Account not found' }), 404
  rescue => e
    logger.error "Get status error: #{e.message}"
    json({ error: 'Failed to get status' }), 500
  end
end

# Analytics
get '/api/analytics' do
  authenticate_user!
  begin
    total_followers = @current_user.facebook_accounts.sum(:followers_count) || 0
    total_following = @current_user.facebook_accounts.sum(:following_count) || 0
    total_likes = @current_user.facebook_accounts.sum(:likes_count) || 0
    
    recent_activity = FollowerLog.where(facebook_account: @current_user.facebook_accounts)
                                 .order(created_at: :desc)
                                 .limit(20)
    
    json({
      stats: {
        total_followers: total_followers,
        total_following: total_following,
        total_likes: total_likes,
        accounts_count: @current_user.facebook_accounts.count
      },
      recent_activity: recent_activity.map { |log| {
        action: log.action,
        target: log.target,
        success: log.success,
        created_at: log.created_at.iso8601
      }}
    })
  rescue => e
    logger.error "Analytics error: #{e.message}"
    json({ error: 'Failed to fetch analytics' }), 500
  end
end

# Settings
get '/api/settings' do
  authenticate_user!
  begin
    json({
      user: {
        email: @current_user.email,
        username: @current_user.username,
        created_at: @current_user.created_at.iso8601
      }
    })
  rescue => e
    logger.error "Get settings error: #{e.message}"
    json({ error: 'Failed to fetch settings' }), 500
  end
end

put '/api/settings' do
  authenticate_user!
  begin
    data = JSON.parse(request.body.read)
    
    # Validate required fields
    unless data['username'] && data['email']
      return json({ error: 'Username and email required' }), 400
    end
    
    # Check if username is already taken by another user
    if User.where.not(id: @current_user.id).exists?(username: data['username'])
      return json({ error: 'Username already taken' }), 400
    end
    
    # Check if email is already taken by another user
    if User.where.not(id: @current_user.id).exists?(email: data['email'])
      return json({ error: 'Email already taken' }), 400
    end
    
    @current_user.update!(
      username: data['username'],
      email: data['email']
    )
    
    json({ success: true, message: 'Settings updated' })
  rescue JSON::ParserError
    json({ error: 'Invalid JSON' }), 400
  rescue => e
    logger.error "Update settings error: #{e.message}"
    json({ error: 'Failed to update settings' }), 500
  end
end

# Anti-Detection System
get '/api/anti-detection/stats' do
  authenticate_user!
  begin
    accounts = @current_user.facebook_accounts
    
    # Calculate safety score
    safety_score = calculate_safety_score(accounts)
    
    # Get anti-detection stats
    stats = get_anti_detection_stats(accounts)
    
    json({
      safety_score: safety_score,
      actions_today: stats[:actions_today],
      daily_limit: stats[:daily_limit],
      next_break: stats[:next_break],
      current_delay: stats[:current_delay],
      risk_factor: stats[:risk_factor],
      time_factor: stats[:time_factor],
      account_age_factor: stats[:account_age_factor],
      timing_pattern: stats[:timing_pattern],
      account_priorities: stats[:account_priorities],
      next_rotation: stats[:next_rotation],
      safety_warnings: stats[:safety_warnings]
    })
  rescue => e
    logger.error "Anti-detection stats error: #{e.message}"
    json({ error: 'Failed to fetch anti-detection stats' }), 500
  end
end

post '/api/anti-detection/safety-level' do
  authenticate_user!
  begin
    data = JSON.parse(request.body.read)
    
    unless data['level'] && %w[conservative balanced aggressive].include?(data['level'])
      return json({ error: 'Invalid safety level' }), 400
    end
    
    # Update safety level for all user accounts
    @current_user.facebook_accounts.update_all(safety_level: data['level'])
    
    json({ success: true, message: "Safety level updated to #{data['level']}" })
  rescue JSON::ParserError
    json({ error: 'Invalid JSON' }), 400
  rescue => e
    logger.error "Safety level update error: #{e.message}"
    json({ error: 'Failed to update safety level' }), 500
  end
end

post '/api/anti-detection/pause-account/:account_id' do
  authenticate_user!
  begin
    account = @current_user.facebook_accounts.find(params[:account_id])
    
    # Pause account for safety
    pause_duration = rand(2..6).hours
    account.update!(status: 'paused', paused_until: Time.now + pause_duration)
    
    json({ 
      success: true, 
      message: "Account paused for safety",
      pause_duration: pause_duration / 3600
    })
  rescue ActiveRecord::RecordNotFound
    json({ error: 'Account not found' }), 404
  rescue => e
    logger.error "Account pause error: #{e.message}"
    json({ error: 'Failed to pause account' }), 500
  end
end

post '/api/anti-detection/resume-account/:account_id' do
  authenticate_user!
  begin
    account = @current_user.facebook_accounts.find(params[:account_id])
    
    # Resume account
    account.update!(status: 'active', paused_until: nil)
    
    json({ success: true, message: "Account resumed" })
  rescue ActiveRecord::RecordNotFound
    json({ error: 'Account not found' }), 404
  rescue => e
    logger.error "Account resume error: #{e.message}"
    json({ error: 'Failed to resume account' }), 500
  end
end

get '/api/anti-detection/account-safety/:account_id' do
  authenticate_user!
  begin
    account = @current_user.facebook_accounts.find(params[:account_id])
    
    # Get detailed safety analysis
    safety_analysis = analyze_account_safety(account)
    
    json(safety_analysis)
  rescue ActiveRecord::RecordNotFound
    json({ error: 'Account not found' }), 404
  rescue => e
    logger.error "Account safety analysis error: #{e.message}"
    json({ error: 'Failed to analyze account safety' }), 500
  end
end

# Error handlers
error 404 do
  json({ error: 'Not found' })
end

error 500 do
  json({ error: 'Internal server error' })
end

private

def authenticate_facebook(email, password)
  # Facebook authentication logic from original code
  api_key = '882a8490361da98702bf97a021ddc14d'
  sig_data = "api_key=#{api_key}credentials_type=passwordemail=#{email}format=JSONgenerate_machine_id=1generate_session_cookies=1locale=en_USmethod=auth.loginpassword=#{password}return_ssl_resources=0v=1.062f8ce9f74b12f84c123cc23437a4a32"
  
  sig = Digest::MD5.hexdigest(sig_data)
  
  response = HTTParty.get('https://api.facebook.com/restserver.php', {
    query: {
      api_key: api_key,
      credentials_type: 'password',
      email: email,
      format: 'JSON',
      generate_machine_id: '1',
      generate_session_cookies: '1',
      locale: 'en_US',
      method: 'auth.login',
      password: password,
      return_ssl_resources: '0',
      v: '1.0',
      sig: sig
    },
    headers: {
      'User-Agent' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_3_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 [FBAN/FBIOS;FBDV/iPhone12,5;FBMD/iPhone;FBSN/iOS;FBSV/13.3.1;FBSS/3;FBID/phone;FBLC/en_US;FBOP/5;FBCR/]'
    },
    timeout: 30
  })
  
  result = JSON.parse(response.body)
  
  if result['access_token']
    return result['access_token']
  elsif result['error_msg']&.include?('www.facebook.com')
    raise 'Account locked. Please try another account.'
  else
    raise 'Invalid credentials'
  end
rescue HTTParty::Error => e
  raise "Network error: #{e.message}"
rescue JSON::ParserError => e
  raise "Invalid response from Facebook"
rescue => e
  raise "Authentication failed: #{e.message}"
end

def calculate_safety_score(accounts)
  return 100 if accounts.empty?
  
  total_score = 0
  account_count = accounts.count
  
  accounts.each do |account|
    score = 100
    
    # Reduce score for new accounts
    account_age_days = ((Time.now - account.created_at) / 1.day).to_i
    if account_age_days < 30
      score -= 20
    elsif account_age_days < 90
      score -= 10
    end
    
    # Reduce score for low follower counts
    if account.followers_count < 100
      score -= 15
    elsif account.followers_count < 500
      score -= 5
    end
    
    # Reduce score for high recent activity
    recent_actions = FollowerLog.where(facebook_account: account)
                               .where('created_at > ?', 24.hours.ago)
                               .count
    
    if recent_actions > 50
      score -= 25
    elsif recent_actions > 30
      score -= 15
    elsif recent_actions > 20
      score -= 10
    end
    
    total_score += [score, 0].max
  end
  
  (total_score / account_count).round
end

def get_anti_detection_stats(accounts)
  return default_stats if accounts.empty?
  
  # Calculate total actions today
  actions_today = FollowerLog.where(facebook_account: accounts)
                             .where('created_at > ?', Date.today.beginning_of_day)
                             .count
  
  # Calculate daily limit
  daily_limit = accounts.sum { |acc| calculate_account_daily_limit(acc) }
  
  # Calculate next break
  next_break = calculate_next_break(accounts)
  
  # Calculate current delay
  current_delay = calculate_current_delay(accounts)
  
  # Calculate risk factors
  risk_factor = calculate_overall_risk_factor(accounts)
  time_factor = calculate_time_factor
  account_age_factor = calculate_overall_account_age_factor(accounts)
  
  # Get timing pattern
  timing_pattern = get_timing_pattern
  
  # Calculate account priorities
  account_priorities = calculate_account_priorities(accounts)
  
  # Calculate next rotation
  next_rotation = calculate_next_rotation
  
  # Get safety warnings
  safety_warnings = get_safety_warnings(accounts)
  
  {
    actions_today: actions_today,
    daily_limit: daily_limit,
    next_break: next_break,
    current_delay: current_delay,
    risk_factor: risk_factor,
    time_factor: time_factor,
    account_age_factor: account_age_factor,
    timing_pattern: timing_pattern,
    account_priorities: account_priorities,
    next_rotation: next_rotation,
    safety_warnings: safety_warnings
  }
end

def calculate_account_daily_limit(account)
  base_limit = 50
  
  # Adjust based on account age
  account_age_days = ((Time.now - account.created_at) / 1.day).to_i
  if account_age_days < 30
    base_limit = 20
  elsif account_age_days < 90
    base_limit = 35
  elsif account_age_days < 365
    base_limit = 45
  else
    base_limit = 60
  end
  
  # Adjust based on follower count
  if account.followers_count < 100
    base_limit = [base_limit, 30].min
  elsif account.followers_count > 1000
    base_limit = [base_limit, 80].min
  end
  
  base_limit
end

def calculate_next_break(accounts)
  # Calculate when next break should occur
  recent_actions = FollowerLog.where(facebook_account: accounts)
                             .where('created_at > ?', 1.hour.ago)
                             .count
  
  if recent_actions > 15
    '5m'  # Break soon
  elsif recent_actions > 10
    '15m' # Break in 15 minutes
  else
    '30m' # Break in 30 minutes
  end
end

def calculate_current_delay(accounts)
  # Calculate current delay based on recent activity
  recent_actions = FollowerLog.where(facebook_account: accounts)
                             .where('created_at > ?', 1.hour.ago)
                             .count
  
  base_delay = 180 # 3 minutes
  
  if recent_actions > 20
    base_delay = 300 # 5 minutes
  elsif recent_actions > 15
    base_delay = 240 # 4 minutes
  elsif recent_actions > 10
    base_delay = 180 # 3 minutes
  end
  
  minutes = base_delay / 60
  seconds = base_delay % 60
  "#{minutes}m #{seconds}s"
end

def calculate_overall_risk_factor(accounts)
  return 1.0 if accounts.empty?
  
  total_risk = 0
  account_count = accounts.count
  
  accounts.each do |account|
    risk = 1.0
    
    # Increase risk for recent activity
    recent_actions = FollowerLog.where(facebook_account: account)
                               .where('created_at > ?', 24.hours.ago)
                               .count
    
    if recent_actions > 50
      risk *= 2.0
    elsif recent_actions > 30
      risk *= 1.5
    elsif recent_actions > 20
      risk *= 1.2
    end
    
    total_risk += risk
  end
  
  (total_risk / account_count).round(1)
end

def calculate_time_factor
  hour = Time.now.hour
  
  if hour.between?(9, 11) || hour.between?(19, 22)
    1.3 # Peak hours
  elsif hour.between?(2, 6)
    0.8 # Off-peak hours
  else
    1.0 # Normal hours
  end
end

def calculate_overall_account_age_factor(accounts)
  return 1.0 if accounts.empty?
  
  total_factor = 0
  account_count = accounts.count
  
  accounts.each do |account|
    account_age_days = ((Time.now - account.created_at) / 1.day).to_i
    
    if account_age_days < 30
      total_factor += 2.0
    elsif account_age_days < 90
      total_factor += 1.5
    elsif account_age_days < 365
      total_factor += 1.2
    else
      total_factor += 1.0
    end
  end
  
  (total_factor / account_count).round(1)
end

def get_timing_pattern
  patterns = ['burst', 'steady', 'sporadic', 'slow', 'mixed']
  patterns.sample
end

def calculate_account_priorities(accounts)
  accounts.map.with_index do |account, index|
    score = 100
    
    # Reduce score for recently used accounts
    score -= index * 5
    
    # Reduce score for accounts with high usage today
    today_usage = FollowerLog.where(facebook_account: account)
                             .where('created_at > ?', Date.today.beginning_of_day)
                             .count
    score -= today_usage * 3
    
    # Reduce score for new accounts
    account_age_days = ((Time.now - account.created_at) / 1.day).to_i
    score -= (30 - account_age_days) * 2 if account_age_days < 30
    
    # Reduce score for accounts with low followers
    if account.followers_count < 100
      score -= 20
    elsif account.followers_count < 500
      score -= 10
    end
    
    {
      id: account.id,
      email: account.email,
      score: [score, 0].max
    }
  end.sort_by { |acc| -acc[:score] }
end

def calculate_next_rotation
  # Calculate when next account rotation should occur
  hours = rand(2..6)
  minutes = rand(0..59)
  "#{hours}h #{minutes}m"
end

def get_safety_warnings(accounts)
  warnings = []
  
  accounts.each do |account|
    # Check for too many recent actions
    recent_actions = FollowerLog.where(facebook_account: account)
                               .where('created_at > ?', 1.hour.ago)
                               .count
    
    if recent_actions > 15
      warnings << "Account #{account.email}: Too many actions recently"
    end
    
    # Check for new accounts
    account_age_days = ((Time.now - account.created_at) / 1.day).to_i
    if account_age_days < 30
      warnings << "Account #{account.email}: Account too new"
    end
    
    # Check for low follower counts
    if account.followers_count < 100
      warnings << "Account #{account.email}: Low follower count"
    end
  end
  
  warnings
end

def analyze_account_safety(account)
  # Perform detailed safety analysis
  account_age_days = ((Time.now - account.created_at) / 1.day).to_i
  recent_actions = FollowerLog.where(facebook_account: account)
                             .where('created_at > ?', 24.hours.ago)
                             .count
  hourly_actions = FollowerLog.where(facebook_account: account)
                             .where('created_at > ?', 1.hour.ago)
                             .count
  
  safety_score = 100
  
  # Reduce score for new accounts
  if account_age_days < 30
    safety_score -= 20
  elsif account_age_days < 90
    safety_score -= 10
  end
  
  # Reduce score for high activity
  if recent_actions > 50
    safety_score -= 25
  elsif recent_actions > 30
    safety_score -= 15
  elsif recent_actions > 20
    safety_score -= 10
  end
  
  # Reduce score for high hourly activity
  if hourly_actions > 15
    safety_score -= 20
  elsif hourly_actions > 10
    safety_score -= 10
  end
  
  # Reduce score for low follower count
  if account.followers_count < 100
    safety_score -= 15
  elsif account.followers_count < 500
    safety_score -= 5
  end
  
  {
    account_id: account.id,
    email: account.email,
    safety_score: [safety_score, 0].max,
    account_age_days: account_age_days,
    followers_count: account.followers_count,
    recent_actions_24h: recent_actions,
    recent_actions_1h: hourly_actions,
    status: account.status,
    recommendations: generate_safety_recommendations(account, safety_score)
  }
end

def generate_safety_recommendations(account, safety_score)
  recommendations = []
  
  if safety_score < 50
    recommendations << "Pause account immediately for 24 hours"
    recommendations << "Reduce daily action limit to 20"
  elsif safety_score < 70
    recommendations << "Take a 6-hour break"
    recommendations << "Reduce daily action limit to 30"
  elsif safety_score < 85
    recommendations << "Take a 2-hour break"
    recommendations << "Increase delays between actions"
  end
  
  # Account age recommendations
  account_age_days = ((Time.now - account.created_at) / 1.day).to_i
  if account_age_days < 30
    recommendations << "Use conservative settings for new account"
  end
  
  # Follower count recommendations
  if account.followers_count < 100
    recommendations << "Focus on organic growth before automation"
  end
  
  recommendations
end

def default_stats
  {
    actions_today: 0,
    daily_limit: 50,
    next_break: '30m',
    current_delay: '3m 0s',
    risk_factor: 1.0,
    time_factor: 1.0,
    account_age_factor: 1.0,
    timing_pattern: 'steady',
    account_priorities: [],
    next_rotation: '4h 0m',
    safety_warnings: []
  }
end
end 