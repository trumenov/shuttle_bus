class AddUserNotifications < ActiveRecord::Migration[6.0]
  def self.up
    create_table :user_notifications, { options: "ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci" } do |t|
      t.references :user, foreign_key: true, index: true
      t.text :notification_msg_text
      t.json :notification_data_json
      t.datetime :sended_at
      t.timestamps null: false
    end

    create_table :user_push_subscribtions, { options: "ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci" } do |t|
      t.references :user, foreign_key: true, index: true
      t.json :push_subscribtion_data_json
      t.datetime :last_success_sended_at
      t.timestamps null: false
    end
  end

  def self.down
    drop_table :user_notifications
    drop_table :user_push_subscribtions
  end
end
