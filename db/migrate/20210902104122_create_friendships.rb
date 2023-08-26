class CreateFriendships < ActiveRecord::Migration[6.0]
  def change
    create_table :friendships, { options: "ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci" } do |t|
      t.references :friend_one, references: :users, foreign_key: { to_table: :users }, index: true, null: false
      t.references :friend_two, references: :users, foreign_key: { to_table: :users }, index: true, null: false

      t.timestamps null: false
    end

    add_index :friendships, [:friend_one_id, :friend_two_id], unique: true
  end
end
