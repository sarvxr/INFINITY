module AntiDetection
  class SmartRateLimiter
    def initialize
      @action_history = {}
      @daily_stats = {}
      @hourly_stats = {}
      @session_start = Time.now
    end

    def calculate_safe_delay(account_id, action_type)
      base_delay = get_base_delay(action_type)
      risk_factor = calculate_risk_factor(account_id)
      time_factor = calculate_time_factor
      account_age_factor = calculate_account_age_factor(account_id)
      
      final_delay = base_delay * risk_factor * time_factor * account_age_factor
      
      # Ensure minimum and maximum delays
      final_delay = [final_delay, 30].max  # Minimum 30 seconds
      final_delay = [final_delay, 3600].min # Maximum 1 hour
      
      final_delay.to_i
    end

    def get_base_delay(action_type)
      case action_type
      when 'follow'
        rand(120..300)  # 2-5 minutes
      when 'unfollow'
        rand(180..420)  # 3-7 minutes
      when 'like'
        rand(60..180)   # 1-3 minutes
      when 'comment'
        rand(300..600)  # 5-10 minutes
      else
        rand(120..240)  # 2-4 minutes
      end
    end

    def calculate_risk_factor(account_id)
      recent_actions = get_recent_actions(account_id, 24.hours)
      daily_total = get_daily_total(account_id)
      
      risk = 1.0
      
      # Increase risk if too many actions recently
      if recent_actions > 50
        risk *= 2.0
      elsif recent_actions > 30
        risk *= 1.5
      elsif recent_actions > 20
        risk *= 1.2
      end
      
      # Increase risk if daily limit is approaching
      if daily_total > 80
        risk *= 3.0
      elsif daily_total > 60
        risk *= 2.0
      elsif daily_total > 40
        risk *= 1.5
      end
      
      # Random variation to avoid patterns
      risk *= rand(0.8..1.2)
      
      risk
    end

    def calculate_time_factor
      hour = Time.now.hour
      
      # Peak hours (more risky)
      if hour.between?(9, 11) || hour.between?(19, 22)
        rand(1.2..1.5)
      # Off-peak hours (safer)
      elsif hour.between?(2, 6)
        rand(0.7..0.9)
      # Normal hours
      else
        rand(0.9..1.1)
      end
    end

    def calculate_account_age_factor(account_id)
      account_age_days = get_account_age_days(account_id)
      
      if account_age_days < 30
        2.0  # New accounts need more care
      elsif account_age_days < 90
        1.5
      elsif account_age_days < 365
        1.2
      else
        1.0  # Old accounts are safer
      end
    end

    def should_take_break?(account_id)
      recent_actions = get_recent_actions(account_id, 1.hour)
      daily_total = get_daily_total(account_id)
      
      # Take break if too many actions in short time
      return true if recent_actions > 15
      
      # Take break if approaching daily limit
      return true if daily_total > 90
      
      # Random breaks to avoid patterns
      return true if rand(1..100) <= 5  # 5% chance
      
      false
    end

    def get_break_duration(account_id)
      base_break = 15.minutes
      risk_factor = calculate_risk_factor(account_id)
      
      break_time = base_break * risk_factor
      break_time = [break_time, 2.hours].min
      break_time = [break_time, 30.minutes].max
      
      break_time.to_i
    end

    def record_action(account_id, action_type)
      now = Time.now
      
      @action_history[account_id] ||= []
      @action_history[account_id] << { type: action_type, time: now }
      
      # Clean old records (keep last 24 hours)
      @action_history[account_id].reject! { |action| action[:time] < 24.hours.ago }
      
      # Update daily stats
      today = now.to_date
      @daily_stats[account_id] ||= {}
      @daily_stats[account_id][today] ||= 0
      @daily_stats[account_id][today] += 1
      
      # Update hourly stats
      hour = now.hour
      @hourly_stats[account_id] ||= {}
      @hourly_stats[account_id][hour] ||= 0
      @hourly_stats[account_id][hour] += 1
    end

    private

    def get_recent_actions(account_id, time_window)
      return 0 unless @action_history[account_id]
      
      cutoff_time = Time.now - time_window
      @action_history[account_id].count { |action| action[:time] > cutoff_time }
    end

    def get_daily_total(account_id)
      today = Date.today
      @daily_stats.dig(account_id, today) || 0
    end

    def get_account_age_days(account_id)
      # This would be fetched from database in real implementation
      # For now, return a random age between 30 and 1000 days
      rand(30..1000)
    end
  end

  class HumanBehaviorSimulator
    def initialize
      @typing_speeds = {}
      @mouse_movements = {}
      @session_patterns = {}
    end

    def simulate_human_delay
      # Simulate human thinking time
      thinking_time = rand(2..8)
      
      # Simulate typing time (if applicable)
      typing_time = rand(1..5)
      
      # Simulate reading time
      reading_time = rand(3..12)
      
      thinking_time + typing_time + reading_time
    end

    def simulate_mouse_movement
      # Simulate realistic mouse movement patterns
      movements = []
      
      # Generate random mouse movements
      rand(3..8).times do
        movements << {
          x: rand(100..800),
          y: rand(100..600),
          duration: rand(50..300)
        }
      end
      
      movements
    end

    def simulate_scroll_behavior
      # Simulate realistic scrolling patterns
      scroll_events = []
      
      # Random scroll events
      rand(2..6).times do
        scroll_events << {
          direction: rand(2) == 0 ? 'up' : 'down',
          distance: rand(100..500),
          speed: rand(50..200)
        }
      end
      
      scroll_events
    end

    def get_realistic_session_duration
      # Simulate realistic session durations
      durations = [
        15.minutes, 30.minutes, 45.minutes, 1.hour, 1.5.hours, 2.hours
      ]
      
      durations.sample + rand(-10.minutes..10.minutes)
    end

    def should_end_session?
      # Random session ending (realistic behavior)
      rand(1..100) <= 15  # 15% chance to end session
    end
  end

  class AccountRotator
    def initialize
      @account_usage = {}
      @last_used = {}
    end

    def select_best_account(accounts)
      return nil if accounts.empty?
      
      # Score each account based on various factors
      scored_accounts = accounts.map do |account|
        score = calculate_account_score(account)
        { account: account, score: score }
      end
      
      # Sort by score (highest first)
      scored_accounts.sort_by { |item| -item[:score] }
      
      # Return the best account
      scored_accounts.first[:account]
    end

    def calculate_account_score(account)
      score = 100
      
      # Reduce score for recently used accounts
      if @last_used[account.id]
        hours_since_last_use = (Time.now - @last_used[account.id]) / 3600
        score -= (24 - hours_since_last_use) * 2 if hours_since_last_use < 24
      end
      
      # Reduce score for accounts with high usage today
      today_usage = @account_usage.dig(account.id, Date.today) || 0
      score -= today_usage * 3
      
      # Reduce score for new accounts
      account_age_days = get_account_age_days(account)
      score -= (30 - account_age_days) * 2 if account_age_days < 30
      
      # Reduce score for accounts with low followers
      if account.followers_count < 100
        score -= 20
      elsif account.followers_count < 500
        score -= 10
      end
      
      # Add random variation
      score += rand(-10..10)
      
      [score, 0].max
    end

    def record_account_usage(account_id)
      today = Date.today
      @account_usage[account_id] ||= {}
      @account_usage[account_id][today] ||= 0
      @account_usage[account_id][today] += 1
      
      @last_used[account_id] = Time.now
    end

    private

    def get_account_age_days(account)
      # This would be fetched from database in real implementation
      rand(30..1000)
    end
  end

  class PatternRandomizer
    def initialize
      @action_patterns = []
      @timing_patterns = []
    end

    def randomize_action_sequence(actions)
      # Randomize the order of actions
      actions.shuffle
    end

    def add_random_actions(planned_actions)
      # Add random actions to make behavior more human-like
      random_actions = []
      
      # Random likes
      if rand(1..100) <= 30
        random_actions << { type: 'like', target: generate_random_target }
      end
      
      # Random comments (rare)
      if rand(1..100) <= 5
        random_actions << { type: 'comment', target: generate_random_target, text: generate_random_comment }
      end
      
      # Random shares (very rare)
      if rand(1..100) <= 2
        random_actions << { type: 'share', target: generate_random_target }
      end
      
      planned_actions + random_actions
    end

    def generate_random_target
      # Generate random target IDs
      targets = [
        '61556700146677', '100000000000001', '100000000000002',
        '100000000000003', '100000000000004', '100000000000005'
      ]
      targets.sample
    end

    def generate_random_comment
      comments = [
        'Great content! 👍',
        'Love this! ❤️',
        'Amazing! 🔥',
        'Keep it up! 💪',
        'Awesome! 🌟',
        'Nice! 😊',
        'Fantastic! 🎉',
        'Brilliant! ✨'
      ]
      comments.sample
    end

    def randomize_timing_pattern
      # Create random timing patterns
      patterns = [
        'burst',      # Multiple actions quickly
        'steady',     # Regular intervals
        'sporadic',   # Random intervals
        'slow',       # Long delays
        'mixed'       # Combination of patterns
      ]
      
      patterns.sample
    end
  end

  class SafetyMonitor
    def initialize
      @warning_signs = []
      @account_status = {}
    end

    def check_account_safety(account_id)
      warnings = []
      
      # Check for suspicious patterns
      warnings << 'Too many actions in short time' if too_many_recent_actions?(account_id)
      warnings << 'Unusual activity pattern' if unusual_pattern_detected?(account_id)
      warnings << 'Account age too new' if account_too_new?(account_id)
      warnings << 'Low follower count' if low_follower_count?(account_id)
      
      # Check for Facebook warning signs
      warnings << 'Account may be flagged' if account_flagged?(account_id)
      warnings << 'Unusual login pattern' if unusual_login_pattern?(account_id)
      
      warnings
    end

    def should_pause_account?(account_id)
      warnings = check_account_safety(account_id)
      
      # Pause if too many warnings
      return true if warnings.length >= 3
      
      # Pause if critical warnings
      return true if warnings.any? { |w| w.include?('flagged') || w.include?('suspended') }
      
      false
    end

    def get_pause_duration(account_id)
      warnings = check_account_safety(account_id)
      
      case warnings.length
      when 1
        2.hours
      when 2
        6.hours
      when 3
        12.hours
      else
        24.hours
      end
    end

    private

    def too_many_recent_actions?(account_id)
      # Implementation would check recent action count
      false
    end

    def unusual_pattern_detected?(account_id)
      # Implementation would analyze action patterns
      false
    end

    def account_too_new?(account_id)
      # Implementation would check account age
      false
    end

    def low_follower_count?(account_id)
      # Implementation would check follower count
      false
    end

    def account_flagged?(account_id)
      # Implementation would check for Facebook warnings
      false
    end

    def unusual_login_pattern?(account_id)
      # Implementation would check login patterns
      false
    end
  end
end 