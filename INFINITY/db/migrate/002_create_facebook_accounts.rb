class CreateFacebookAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :facebook_accounts do |t|
      t.references :user, null: false, foreign_key: true
      t.string :email, null: false
      t.text :access_token, null: false
      t.string :status, default: 'active'
      t.integer :followers_count, default: 0
      t.integer :following_count, default: 0
      t.integer :likes_count, default: 0
      
      # Anti-detection fields
      t.string :safety_level, default: 'balanced'  # conservative, balanced, aggressive
      t.datetime :paused_until
      t.integer :daily_action_limit, default: 50
      t.integer :hourly_action_limit, default: 10
      t.integer :consecutive_failures, default: 0
      t.datetime :last_action_at
      t.datetime :last_break_at
      t.integer :total_actions_today, default: 0
      t.integer :total_actions_this_hour, default: 0
      t.float :risk_factor, default: 1.0
      t.boolean :safety_paused, default: false
      t.text :safety_warnings
      t.integer :account_age_days
      t.float :safety_score, default: 100.0
      
      t.timestamps
    end

    add_index :facebook_accounts, :email
    add_index :facebook_accounts, :status
    add_index :facebook_accounts, :safety_level
    add_index :facebook_accounts, :safety_paused
    add_index :facebook_accounts, :last_action_at
    add_index :facebook_accounts, :paused_until
  end
end 