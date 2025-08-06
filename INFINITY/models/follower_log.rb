class FollowerLog < ActiveRecord::Base
  belongs_to :facebook_account
  
  validates :action, presence: true, inclusion: { in: %w[follow unfollow like unlike] }
  validates :target, presence: true
  validates :success, inclusion: { in: [true, false] }
  
  scope :successful, -> { where(success: true) }
  scope :failed, -> { where(success: false) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_action, ->(action) { where(action: action) }
  
  def self.stats_for_account(account_id, days = 7)
    start_date = days.days.ago
    
    where(facebook_account_id: account_id, created_at: start_date..Time.now)
      .group(:action, :success)
      .count
  end
  
  def self.daily_stats_for_account(account_id, days = 7)
    start_date = days.days.ago
    
    where(facebook_account_id: account_id, created_at: start_date..Time.now)
      .group("DATE(created_at)")
      .group(:action)
      .count
  end
  
  def action_icon
    case action
    when 'follow'
      '👥'
    when 'unfollow'
      '🚶'
    when 'like'
      '❤️'
    when 'unlike'
      '💔'
    else
      '❓'
    end
  end
  
  def status_text
    success ? 'Success' : 'Failed'
  end
  
  def status_color
    success ? 'text-green-600' : 'text-red-600'
  end
  
  def formatted_created_at
    created_at.strftime('%Y-%m-%d %H:%M:%S')
  end
  
  def time_ago
    time_diff = Time.now - created_at
    
    if time_diff < 60
      "#{time_diff.to_i} seconds ago"
    elsif time_diff < 3600
      "#{(time_diff / 60).to_i} minutes ago"
    elsif time_diff < 86400
      "#{(time_diff / 3600).to_i} hours ago"
    else
      "#{(time_diff / 86400).to_i} days ago"
    end
  end
end 