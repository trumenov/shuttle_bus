class AddUserDeletedWithEmail < ActiveRecord::Migration[6.0]
  def self.up
    change_table :users do |t|
      t.text :deleted_with_email, after: :deleted_at
    end
  end
end
