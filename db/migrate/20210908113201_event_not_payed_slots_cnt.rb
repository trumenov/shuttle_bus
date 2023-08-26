class EventNotPayedSlotsCnt < ActiveRecord::Migration[6.0]
  def self.up
    add_column :events, :not_payed_slots_cnt, :integer, after: :event_finish_time, null: false, default: 0
    add_column :event_ticket_packs, :tickets_slotted_cnt, :integer, after: :pack_capacity, null: false, default: 0
    remove_column :events, :price_eur
    remove_column :events, :number_of_participants_max
    remove_column :events, :status
    remove_column :tickets, :payed_eur_cts
    remove_column :tickets, :ticket_refunded_at
  end

  def self.down
    remove_column :events, :not_payed_slots_cnt
    remove_column :event_ticket_packs, :tickets_slotted_cnt
    add_column :events, :price_eur, :decimal, after: :event_finish_time, null: false, default: 0
    add_column :events, :number_of_participants_max, :integer, after: :event_finish_time, null: false, default: 0
    add_column :events, :status, :integer, after: :search_text, null: false, default: 0, limit: 1

    add_column :tickets, :payed_eur_cts, :integer, after: :cost_eur_cts, null: false, default: 0
    add_column :tickets, :ticket_refunded_at, :datetime, after: :ticket_payed_at
  end
end
