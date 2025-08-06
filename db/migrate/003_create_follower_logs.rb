class CreateFollowerLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :follower_logs do |t|
      t.references :facebook_account, null: false, foreign_key: true
      t.string :action, null: false
      t.string :target, null: false
      t.boolean :success, default: false
      t.text :response_data
      t.timestamps
    end
    
    add_index :follower_logs, :action
    add_index :follower_logs, :success
    add_index :follower_logs, :created_at
  end
end 