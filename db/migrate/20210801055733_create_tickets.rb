class CreateTickets < ActiveRecord::Migration[6.0]
  def change
    create_table :tickets, { options: "ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci" } do |t|
      t.text :name
      t.integer :ticket_status, default: 0, null: false, limit: 1, comment: '0-created, 2-payment_fail, 3-payment_refunded, 5-refund_need, 8-ticket_payed, 9-ticket_used'
      t.references :user             , null: false, foreign_key: true, index: true
      t.references :event_ticket_pack, null: false, foreign_key: true, index: true
      t.integer :cost_eur_cts, null: false, default: 0
      t.integer :payed_eur_cts, null: false, default: 0
      t.datetime :ticket_checkout_at, limit: 0
      t.datetime :ticket_payed_at, limit: 0
      t.datetime :ticket_refunded_at, limit: 0
      t.datetime :ticket_used_at, limit: 0
      t.text :search_text
      t.timestamps null: false
    end

    create_table :tickets_payments, { options: "ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci" } do |t|
      t.references :ticket, null: false, foreign_key: true, index: true
      t.string :gateway_name, null: false, limit: 8
      t.integer :amount_cts, null: false
      t.integer :amount_accepted_cts, null: false, default: 0
      t.integer :amount_refunded_cts, null: false, default: 0
      t.integer :application_fee_amount_cts, null: false, default: 0
      t.string :currency, null: false, default: "", limit: 16
      t.string :card_type, default: "", limit: 30
      t.string :card_last4, default: "", limit: 8
      t.string :card_exp_month, default: "", limit: 4
      t.string :card_exp_year, default: "", limit: 8
      t.text :request_info_json
      t.text :response_data_json
      t.datetime :payment_accepted_at, limit: 0
      t.datetime :payment_refunded_at, limit: 0
      t.timestamps null: false
    end
  end
end
