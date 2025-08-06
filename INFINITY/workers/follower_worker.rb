require 'sidekiq'
require 'httparty'
require 'json'
require 'time'
require 'logger'
require_relative '../lib/anti_detection'

class FollowerWorker
  include Sidekiq::Worker
  
  sidekiq_options retry: 3, backtrace: true
  
  def initialize
    @rate_limiter = AntiDetection::SmartRateLimiter.new
    @behavior_simulator = AntiDetection::HumanBehaviorSimulator.new
    @account_rotator = AntiDetection::AccountRotator.new
    @pattern_randomizer = AntiDetection::PatternRandomizer.new
    @safety_monitor = AntiDetection::SafetyMonitor.new
    @session_start = Time.now
    @actions_completed = 0
  end
  
  def perform(account_id, target_count = 10)
    account = FacebookAccount.find(account_id)
    return unless account.active?
    
    logger.info "🚀 Starting ULTIMATE anti-detection follower process for account #{account_id}"
    
    # Check account safety before starting
    safety_warnings = @safety_monitor.check_account_safety(account_id)
    if @safety_monitor.should_pause_account?(account_id)
      pause_duration = @safety_monitor.get_pause_duration(account_id)
      logger.warn "⚠️ Account #{account_id} paused for safety: #{pause_duration / 3600} hours"
      return
    end
    
    # Update current follower counts
    account.update_follower_counts
    
    # Load target IDs from files
    target_ids = load_target_ids
    
    success_count = 0
    failure_count = 0
    
    # Calculate safe daily limits
    daily_limit = calculate_daily_limit(account)
    logger.info "📊 Daily limit for account #{account_id}: #{daily_limit} actions"
    
    target_count.times do |i|
      break unless account.active?
      
      # Check if we should take a break
      if should_take_break?(account_id, success_count, failure_count)
        break_duration = @rate_limiter.get_break_duration(account_id)
        logger.info "🛑 Taking safety break for #{break_duration / 60} minutes"
        sleep(break_duration)
      end
      
      # Check daily limit
      if @actions_completed >= daily_limit
        logger.info "📅 Daily limit reached for account #{account_id}"
        break
      end
      
      # Select target with randomization
      target_id = select_safe_target(target_ids, account_id)
      next unless target_id
      
      # Calculate safe delay
      delay = @rate_limiter.calculate_safe_delay(account_id, 'follow')
      logger.info "⏱️ Waiting #{delay} seconds before next action"
      sleep(delay)
      
      # Add human-like behavior
      add_human_behavior()
      
      # Perform follow action with enhanced safety
      if perform_safe_follow(account, target_id)
        success_count += 1
        @actions_completed += 1
        logger.info "✅ Successfully followed #{target_id} (Total: #{success_count})"
        
        # Record action for rate limiting
        @rate_limiter.record_action(account_id, 'follow')
        
        # Random success celebration delay
        sleep(rand(5..15))
      else
        failure_count += 1
        logger.warn "❌ Failed to follow #{target_id} (Failures: #{failure_count})"
        
        # Increase delay after failure
        sleep(rand(30..60))
      end
      
      # Check for critical failure threshold
      if failure_count >= 3
        logger.warn "🚨 Too many failures, taking extended break"
        sleep(30 * 60) # 30 minutes
        failure_count = 0
      end
      
      # Update progress
      update_progress(account_id, i + 1, target_count, success_count, failure_count)
      
      # Random session breaks
      if should_end_session?()
        session_break = rand(10..30).minutes
        logger.info "🔄 Session break for #{session_break / 60} minutes"
        sleep(session_break)
      end
    end
    
    # Final update
    account.update_follower_counts
    
    logger.info "🎉 Completed ULTIMATE follower process for account #{account_id}: #{success_count} success, #{failure_count} failures"
    
    # Schedule next session if needed
    schedule_next_session(account_id) if success_count > 0
  rescue => e
    logger.error "💥 Error in follower worker for account #{account_id}: #{e.message}"
    raise e
  end
  
  private
  
  def calculate_daily_limit(account)
    base_limit = 50
    
    # Adjust based on account age
    account_age_days = get_account_age_days(account)
    if account_age_days < 30
      base_limit = 20  # New accounts
    elsif account_age_days < 90
      base_limit = 35  # Young accounts
    elsif account_age_days < 365
      base_limit = 45  # Mature accounts
    else
      base_limit = 60  # Old accounts
    end
    
    # Adjust based on follower count
    if account.followers_count < 100
      base_limit = [base_limit, 30].min
    elsif account.followers_count > 1000
      base_limit = [base_limit, 80].min
    end
    
    # Add random variation
    base_limit + rand(-5..5)
  end
  
  def select_safe_target(target_ids, account_id)
    # Filter out recently used targets
    recent_targets = get_recent_targets(account_id)
    safe_targets = target_ids - recent_targets
    
    # If no safe targets, use all targets
    safe_targets = target_ids if safe_targets.empty?
    
    safe_targets.sample
  end
  
  def perform_safe_follow(account, target_id)
    # Add random human-like delays
    sleep(@behavior_simulator.simulate_human_delay)
    
    # Perform the follow action
    success = account.follow_user(target_id)
    
    # Record target usage
    record_target_usage(account.id, target_id)
    
    success
  end
  
  def should_take_break?(account_id, success_count, failure_count)
    # Take break after every 10 successful actions
    return true if success_count > 0 && success_count % 10 == 0
    
    # Take break after 3 failures
    return true if failure_count >= 3
    
    # Random breaks (5% chance)
    return true if rand(1..100) <= 5
    
    # Check rate limiter
    @rate_limiter.should_take_break?(account_id)
  end
  
  def add_human_behavior
    # Simulate mouse movements
    movements = @behavior_simulator.simulate_mouse_movement
    sleep(rand(1..3)) # Simulate movement time
    
    # Simulate scrolling
    scroll_events = @behavior_simulator.simulate_scroll_behavior
    sleep(rand(2..5)) # Simulate scroll time
    
    # Random thinking time
    sleep(rand(3..8))
  end
  
  def should_end_session?
    # End session after 2 hours
    return true if Time.now - @session_start > 2.hours
    
    # Random session ending
    @behavior_simulator.should_end_session?
  end
  
  def schedule_next_session(account_id)
    # Schedule next session with random delay
    next_delay = rand(2..6).hours
    FollowerWorker.perform_in(next_delay, account_id, rand(5..15))
    
    logger.info "📅 Scheduled next session for account #{account_id} in #{next_delay / 3600} hours"
  end
  
  def load_target_ids
    ids = []
    
    # Load from fw.txt
    if File.exist?('fw.txt')
      ids += File.readlines('fw.txt', chomp: true).reject(&:empty?)
    end
    
    # Load from fwl.txt
    if File.exist?('fwl.txt')
      ids += File.readlines('fwl.txt', chomp: true).reject(&:empty?)
    end
    
    # If no IDs found, use some default targets
    if ids.empty?
      ids = [
        '61556700146677',  # Default target from original code
        '100000000000001',
        '100000000000002',
        '100000000000003',
        '100000000000004',
        '100000000000005'
      ]
    end
    
    # Randomize the order
    ids.shuffle.uniq
  end
  
  def get_recent_targets(account_id)
    # Get targets used in the last 24 hours
    recent_logs = FollowerLog.where(facebook_account_id: account_id)
                             .where('created_at > ?', 24.hours.ago)
                             .pluck(:target)
    
    recent_logs.uniq
  end
  
  def record_target_usage(account_id, target_id)
    # Store in Redis for quick access
    Sidekiq.redis do |conn|
      key = "recent_targets:#{account_id}"
      conn.zadd(key, Time.now.to_i, target_id)
      conn.expire(key, 24.hours.to_i)
    end
  end
  
  def get_account_age_days(account)
    # Calculate account age in days
    created_at = account.created_at || Time.now
    ((Time.now - created_at) / 1.day).to_i
  end
  
  def update_progress(account_id, current, total, success, failure)
    progress = {
      account_id: account_id,
      current: current,
      total: total,
      success: success,
      failure: failure,
      percentage: ((current.to_f / total) * 100).round(2),
      timestamp: Time.now.iso8601,
      daily_limit_reached: @actions_completed >= 50,
      safety_status: @safety_monitor.check_account_safety(account_id)
    }
    
    # Store progress in Redis for real-time updates
    Sidekiq.redis do |conn|
      conn.set("follower_progress:#{account_id}", progress.to_json)
      conn.expire("follower_progress:#{account_id}", 3600) # Expire in 1 hour
    end
  end
  
  def logger
    @logger ||= Logger.new(STDOUT)
  end
end 