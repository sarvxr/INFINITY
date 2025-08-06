class User < ActiveRecord::Base
  has_many :facebook_accounts, dependent: :destroy
  has_many :follower_logs, through: :facebook_accounts
  
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :username, presence: true, uniqueness: true, length: { minimum: 3, maximum: 30 }
  validates :password_hash, presence: true
  
  before_validation :set_defaults
  
  def self.authenticate(email, password)
    user = find_by(email: email)
    return nil unless user
    return user if BCrypt::Password.new(user.password_hash) == password
    nil
  end
  
  def update_password(new_password)
    update(password_hash: BCrypt::Password.create(new_password))
  end
  
  def total_followers
    facebook_accounts.sum(:followers_count) || 0
  end
  
  def total_following
    facebook_accounts.sum(:following_count) || 0
  end
  
  def total_likes
    facebook_accounts.sum(:likes_count) || 0
  end
  
  def active_accounts_count
    facebook_accounts.where(status: 'active').count
  end
  
  private
  
  def set_defaults
    self.created_at ||= Time.now
    self.updated_at ||= Time.now
  end
end 