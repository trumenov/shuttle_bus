class AddEventChat < ActiveRecord::Migration[6.0]
  def self.up
    create_table :event_chat_msgs, { options: "ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci" } do |t|
      t.references :event             , null: false, foreign_key: true, index: true
      t.references :user              , null: false, foreign_key: true, index: true
      t.text :msg_html
      t.timestamps null: false
    end

    create_table :event_chat_msg_unreads, { options: "ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci" } do |t|
      t.references :event_chat_msg    , null: false, foreign_key: true, index: true
      t.references :user              , null: false, foreign_key: true, index: true
    end
    add_column :tickets, :event_version, :integer, after: :event_ticket_pack_id
  end

  def self.down
    remove_column :tickets, :event_version
    drop_table :event_chat_msg_unreads
    drop_table :event_chat_msgs
  end
end
