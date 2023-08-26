class AddPiId < ActiveRecord::Migration[6.0]

  def self.up
    remove_column :events, :event_duration_seconds_max
    add_column :events, :event_finish_time, :datetime, after: :event_start_time
    change_column :users, :current_sign_in_ip, :text, null: true, :default => nil
    change_column :users, :last_sign_in_ip   , :text, null: true, :default => nil
    add_column :tickets_payments, :gateway_payment_id, :text, after: :gateway_name
    add_column :tickets_payments, :gateway_payment_need_check, :integer, after: :gateway_payment_id, null: false, default: 0, limit: 1
  end

  def self.down
    add_column :events, :event_duration_seconds_max, :integer, after: :event_start_time, null: false, :default => 0
    remove_column :events, :event_finish_time
    change_column :users, :current_sign_in_ip, :string, null: false, :limit => 20, :default => ''
    change_column :users, :last_sign_in_ip   , :string, null: false, :limit => 20, :default => ''
    remove_column :tickets_payments, :gateway_payment_id
    remove_column :tickets_payments, :gateway_payment_need_check
  end
end
