class CreateFriendRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :friend_requests, { options: "ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci" } do |t|
      t.references :requestor, references: :users, foreign_key: { to_table: :users }, index: true, null: false
      t.references :receiver, references: :users, foreign_key: { to_table: :users }, index: true, null: false
      t.boolean :accepted, null: false, default: false

      t.timestamps null: false
    end
  end
end
