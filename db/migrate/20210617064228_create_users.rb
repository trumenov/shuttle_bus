class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users, { options: "ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci" } do |t|
      t.text :name
      t.string :email, null: false, default: "", limit: 150
      t.text :last_name
      t.string :password_digest, null: false, default: "", limit: 250

      ## Recoverable
      t.text   :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :password_changed_at

      t.text   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at

      t.text :bio
      t.text :phone
      t.text :gender
      t.text :facebook_link
      t.text :instagram_link

      t.timestamps null: false
    end

    add_index :users, :email, unique: true,  :length => 150
    add_index :users, :reset_password_token, :length => 8
    add_index :users, :confirmation_token,   :length => 8
  end
end
