class AddTicketEventSnapshot < ActiveRecord::Migration[6.0]
  def self.up
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE tickets")
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE tickets_payments")
    ActiveRecord::Base.connection.execute("UPDATE event_ticket_packs SET tickets_slotted_cnt=0, tickets_sold_cnt=0, tickets_pay_fail_cnt=0")
    add_column :tickets, :event_finish_at, :datetime, after: :event_version, null: false
    add_column :tickets, :event_starts_at, :datetime, after: :event_version, null: false
    add_column :tickets, :for_owner_eur_cts, :integer, after: :cost_eur_cts, null: false, default: 0
    add_column :tickets, :payed_to_owner_eur_cts, :integer, after: :cost_eur_cts, null: false, default: 0
  end

  def self.down
    remove_column :tickets, :event_finish_at
    remove_column :tickets, :event_starts_at
    remove_column :tickets, :for_owner_eur_cts
    remove_column :tickets, :payed_to_owner_eur_cts
  end
end
