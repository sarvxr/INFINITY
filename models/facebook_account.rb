class FacebookAccount < ActiveRecord::Base
  belongs_to :user
  has_many :follower_logs, dependent: :destroy
  
  validates :email, presence: true
  validates :access_token, presence: true
  validates :status, inclusion: { in: %w[active inactive suspended] }
  
  before_validation :set_defaults
  
  scope :active, -> { where(status: 'active') }
  scope :inactive, -> { where(status: 'inactive') }
  scope :suspended, -> { where(status: 'suspended') }
  
  def update_follower_counts
    begin
      response = HTTParty.get("https://graph.facebook.com/me?fields=subscribers.limit(1).summary(true),subscribedto.limit(1).summary(true),likes.limit(1).summary(true)&access_token=#{access_token}")
      data = JSON.parse(response.body)
      
      if data['subscribers']
        self.followers_count = data['subscribers']['summary']['total_count']
      end
      
      if data['subscribedto']
        self.following_count = data['subscribedto']['summary']['total_count']
      end
      
      if data['likes']
        self.likes_count = data['likes']['summary']['total_count']
      end
      
      save!
    rescue => e
      Rails.logger.error "Error updating follower counts for account #{id}: #{e.message}" if defined?(Rails)
      logger.error "Error updating follower counts for account #{id}: #{e.message}" if respond_to?(:logger)
    end
  end
  
  def follow_user(target_id)
    begin
      response = HTTParty.post("https://graph.facebook.com/#{target_id}/subscribers", {
        query: { access_token: access_token }
      })
      
      success = response.code == 200
      
      FollowerLog.create!(
        facebook_account: self,
        action: 'follow',
        target: target_id,
        success: success,
        response_data: response.body
      )
      
      success
    rescue => e
      FollowerLog.create!(
        facebook_account: self,
        action: 'follow',
        target: target_id,
        success: false,
        response_data: e.message
      )
      false
    end
  end
  
  def unfollow_user(target_id)
    begin
      response = HTTParty.delete("https://graph.facebook.com/#{target_id}/subscribers", {
        query: { access_token: access_token }
      })
      
      success = response.code == 200
      
      FollowerLog.create!(
        facebook_account: self,
        action: 'unfollow',
        target: target_id,
        success: success,
        response_data: response.body
      )
      
      success
    rescue => e
      FollowerLog.create!(
        facebook_account: self,
        action: 'unfollow',
        target: target_id,
        success: false,
        response_data: e.message
      )
      false
    end
  end
  
  def like_page(page_id)
    begin
      response = HTTParty.post("https://graph.facebook.com/#{page_id}/likes", {
        query: { access_token: access_token }
      })
      
      success = response.code == 200
      
      FollowerLog.create!(
        facebook_account: self,
        action: 'like',
        target: page_id,
        success: success,
        response_data: response.body
      )
      
      success
    rescue => e
      FollowerLog.create!(
        facebook_account: self,
        action: 'like',
        target: page_id,
        success: false,
        response_data: e.message
      )
      false
    end
  end
  
  def suspend!
    update!(status: 'suspended')
  end
  
  def activate!
    update!(status: 'active')
  end
  
  def deactivate!
    update!(status: 'inactive')
  end
  
  def suspended?
    status == 'suspended'
  end
  
  def active?
    status == 'active'
  end
  
  def inactive?
    status == 'inactive'
  end
  
  private
  
  def set_defaults
    self.status ||= 'active'
    self.followers_count ||= 0
    self.following_count ||= 0
    self.likes_count ||= 0
    self.created_at ||= Time.now
    self.updated_at ||= Time.now
  end
end 