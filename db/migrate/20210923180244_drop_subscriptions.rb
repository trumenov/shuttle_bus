class DropSubscriptions < ActiveRecord::Migration[6.0]
  def self.up
    drop_table :subscriptions
    rename_table :user_push_subscribtions, :user_push_subscriptions
    rename_column :user_push_subscriptions, :push_subscribtion_data_json, :push_subscription_data_json
  end

  def self.down
    create_table :subscriptions, { options: "ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci" } do |t|
      t.references :event, foreign_key: true, index: true
      t.references :user, foreign_key: true, index: true
      t.text :user_name
      t.text :user_email
      t.integer :event_evaluation, :integer, limit: 1, unsigned: true, null: false, default: 0
      t.timestamps
    end
    rename_table :user_push_subscriptions, :user_push_subscribtions
    rename_column :user_push_subscribtions, :push_subscription_data_json, :push_subscribtion_data_json
  end
end
