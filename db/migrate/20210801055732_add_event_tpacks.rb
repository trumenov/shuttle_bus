class AddEventTpacks < ActiveRecord::Migration[6.0]
  def change
    create_table :event_ticket_packs, { options: "ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci" } do |t|
      t.text :name
      t.references :event, foreign_key: true, index: true
      t.integer :pack_capacity, default: 0, null: false
      t.integer :tickets_sold_cnt, default: 0, null: false
      t.integer :tickets_pay_fail_cnt, default: 0, null: false
      t.decimal :ticket_cost_eur, null: false, default: 0, precision: 8, scale: 2
      t.integer :event_ticket_pack_type, default: 0, null: false, limit: 1, comment: '0-guest, 10-vip, 20-resident'
      t.integer :event_ticket_pack_sale_rule, default: 0, null: false, limit: 1, comment: '0-stopped_sale, 1-simple_sale, 2-with_confirmation'
      t.integer :tpack_version, default: 0, null: false
      t.timestamps null: false
    end

    change_table :events do |t|
      t.integer  :event_version, default: 0, null: false
    end
  end
end
