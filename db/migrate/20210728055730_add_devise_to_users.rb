# frozen_string_literal: true

class AddDeviseToUsers < ActiveRecord::Migration[6.0]
  def self.up
    change_table :users do |t|
      ## Database authenticatable
      t.integer :current_password_unknown, default: 0, null: false, limit: 1 # for oauth2 - random password can not change :(
      t.string :encrypted_password, null: false, default: "", limit: 250
      ## Rememberable
      t.datetime :remember_created_at


      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip, null: false, default: "", limit: 20
      t.string   :last_sign_in_ip, null: false, default: "", limit: 20

      ## Confirmable
      t.text   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      t.text   :unlock_token # Only if unlock strategy is :email or :both
      t.datetime :locked_at
    end

    # add_index :users, :confirmation_token,   unique: true
    # add_index :users, :unlock_token,         unique: true
    add_index :users, :unlock_token,   :length => 8
    remove_column :users, :password_digest
  end

  def self.down
    # By default, we don't want to make any assumption about how to roll back a migration when your
    # model already existed. Please edit below which fields you would like to remove in this migration.
    raise ActiveRecord::IrreversibleMigration
  end
end
