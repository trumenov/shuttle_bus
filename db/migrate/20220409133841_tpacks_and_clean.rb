class TpacksAndClean < ActiveRecord::Migration[6.0]
  def self.up
    create_table :trip_ticket_packs, { id: :unsigned_integer, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci" } do |t|
      t.text :name
      t.references :trip, null: false, foreign_key: true, index: true, :unsigned => true
      t.integer :pack_capacity, default: 0, null: false, :unsigned => true
      t.integer :tickets_sold_cnt, default: 0, null: false, :unsigned => true
      t.integer :tickets_pay_fail_cnt, default: 0, null: false, :unsigned => true
      t.integer :ticket_cost_pts_cts, default: 0, null: false, :unsigned => true
      t.integer :ticket_cost_currency, default: 0, null: false, limit: 1, :unsigned => true, comment: '0-NONE, 1-USD, 2-EUR'
      t.integer :trip_ticket_pack_sale_rule, default: 0, null: false, limit: 1, comment: '0-stopped_sale, 1-simple_sale, 2-with_confirmation'
      t.timestamps null: false
    end

    drop_table :event_chat_msg_unreads
    drop_table :event_chat_msgs
    drop_table :event_imgs
    drop_table :event_props
    drop_table :event_ticket_packs
    drop_table :events
    drop_table :events_filter_fields

    drop_table :friend_requests
    drop_table :reports
    drop_table :reported_users
    drop_table :reviews
    drop_table :tickets
    drop_table :tickets_payments

    create_table :tickets, { id: :unsigned_integer, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci" } do |t|
      t.text :name
      t.integer :slot_status, default: 0, null: false, limit: 1, :unsigned => true, comment: 'created: 0, slot_fail: 1, slot_canceled: 3, slot_declined: 5, slot_asked: 8, slot_accepted: 10, slot_taked: 20'
      t.references :user            , null: false, foreign_key: true, index: true, :unsigned => true
      t.references :trip_ticket_pack, null: false, foreign_key: true, index: true, :unsigned => true
      t.integer :cost_pts_cts, null: false, default: 0, :unsigned => true
      t.integer :payed_pts_cts, null: false, default: 0, :unsigned => true
      t.integer :payed_to_owner_pts_cts, null: false, default: 0, :unsigned => true
      t.datetime :ticket_checkout_at, limit: 0
      t.datetime :ticket_payed_at, limit: 0
      t.datetime :ticket_refunded_at, limit: 0
      t.datetime :ticket_used_at, limit: 0
      t.text :ticket_on_payed_info_json
      t.text :search_text
      t.timestamps null: false
    end

    create_table :ticket_payments, { id: :unsigned_integer, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci" } do |t|
      t.references :ticket, null: false, foreign_key: true, index: true, :unsigned => true
      t.string :gateway_name, null: false, limit: 8
      t.text :gateway_payment_id
      t.integer :gateway_payment_need_check, null: false, default: 0, limit: 1, :unsigned => true
      t.integer :amount_pts_cts, null: false, :unsigned => true
      t.integer :amount_accepted_pts_cts, null: false, default: 0, :unsigned => true
      t.integer :amount_refunded_pts_cts, null: false, default: 0, :unsigned => true
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

  def self.down
    drop_table :trip_ticket_packs
    drop_table :tickets
    drop_table :ticket_payments

    create_table "event_chat_msg_unreads", options: "ENGINE=MyISAM DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
      t.bigint "event_chat_msg_id", null: false
      t.bigint "user_id", null: false
      t.index ["event_chat_msg_id"], name: "index_event_chat_msg_unreads_on_event_chat_msg_id"
      t.index ["user_id"], name: "index_event_chat_msg_unreads_on_user_id"
    end

    create_table "event_chat_msgs", options: "ENGINE=MyISAM DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
      t.bigint "event_id", null: false
      t.bigint "user_id", null: false
      t.text "msg_html"
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.index ["event_id"], name: "index_event_chat_msgs_on_event_id"
      t.index ["user_id"], name: "index_event_chat_msgs_on_user_id"
    end

    create_table "event_imgs", options: "ENGINE=MyISAM DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
      t.bigint "event_id", null: false
      t.integer "prio", default: 0, null: false
      t.text "name"
      t.datetime "deleted_at"
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.index ["event_id"], name: "index_event_imgs_on_event_id"
    end

    create_table "event_props", options: "ENGINE=MyISAM DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
      t.text "name"
      t.bigint "event_id", null: false
      t.integer "pos_id", default: 0, null: false, unsigned: true
      t.bigint "full_sum", default: 0, null: false, unsigned: true
      t.string "prop_pref", limit: 1, default: "N", null: false, collation: "cp1251_general_ci"
      t.text "prop_name"
      t.bigint "prop_name_sum", default: 0, null: false, unsigned: true
      t.text "prop_val"
      t.bigint "prop_val_sum", default: 0, null: false, unsigned: true
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.index ["event_id", "pos_id"], name: "index_event_props_on_event_id_and_pos_id", unique: true
      t.index ["event_id"], name: "index_event_props_on_event_id"
      t.index ["prop_name_sum"], name: "index_event_props_on_prop_name_sum"
      t.index ["prop_val_sum"], name: "index_event_props_on_prop_val_sum"
    end

    create_table "event_ticket_packs", options: "ENGINE=MyISAM DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
      t.text "name"
      t.bigint "event_id"
      t.integer "pack_capacity", default: 0, null: false
      t.integer "tickets_slotted_cnt", default: 0, null: false
      t.integer "tickets_sold_cnt", default: 0, null: false
      t.integer "tickets_pay_fail_cnt", default: 0, null: false
      t.decimal "ticket_cost_eur", precision: 8, scale: 2, default: "0.0", null: false
      t.integer "event_ticket_pack_type", limit: 1, default: 0, null: false, comment: "0-guest, 10-vip, 20-resident"
      t.integer "event_ticket_pack_sale_rule", limit: 1, default: 0, null: false, comment: "0-stopped_sale, 1-simple_sale, 2-with_confirmation"
      t.integer "tpack_version", default: 0, null: false
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.index ["event_id"], name: "index_event_ticket_packs_on_event_id"
    end

    create_table "events", options: "ENGINE=MyISAM DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
      t.text "name"
      t.bigint "user_id", null: false
      t.text "description"
      t.text "house_rules"
      t.text "address"
      t.decimal "latitude", precision: 11, scale: 8
      t.decimal "longitude", precision: 11, scale: 8
      t.datetime "event_start_time"
      t.datetime "event_finish_time"
      t.integer "not_payed_slots_cnt", default: 0, null: false
      t.decimal "place_square_meters", precision: 10, scale: 2
      t.datetime "declined_at"
      t.text "search_text"
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.integer "visibility_status", limit: 1, default: 0, null: false
      t.decimal "rating", precision: 3, scale: 2, default: "0.0", null: false
      t.integer "event_rang_pts", default: 0, null: false, unsigned: true
      t.integer "event_version", default: 0, null: false
      t.text "geography", size: :long, collation: "utf8mb4_bin"
      t.index ["latitude", "longitude"], name: "index_events_on_latitude_and_longitude"
      t.index ["user_id"], name: "index_events_on_user_id"
      t.index ["visibility_status"], name: "index_events_on_visibility_status"
    end

    create_table "events_filter_fields", options: "ENGINE=MyISAM DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
      t.text "name"
      t.integer "show_for_client", limit: 1, default: 0, null: false, unsigned: true
      t.bigint "eff_name_sum", default: 0, null: false, unsigned: true
      t.integer "prio", default: 0, null: false, unsigned: true
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
    end

    create_table "friend_requests", options: "ENGINE=MyISAM DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
      t.bigint "requestor_id", null: false
      t.bigint "receiver_id", null: false
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.index ["receiver_id"], name: "index_friend_requests_on_receiver_id"
      t.index ["requestor_id", "receiver_id"], name: "index_friend_requests_on_requestor_id_and_receiver_id", unique: true
      t.index ["requestor_id"], name: "index_friend_requests_on_requestor_id"
    end

    create_table "reported_users", options: "ENGINE=MyISAM DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
      t.bigint "report_id", null: false
      t.bigint "user_id", null: false
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.index ["report_id", "user_id"], name: "index_reported_users_on_report_id_and_user_id", unique: true
      t.index ["report_id"], name: "index_reported_users_on_report_id"
      t.index ["user_id"], name: "index_reported_users_on_user_id"
    end

    create_table "reports", options: "ENGINE=MyISAM DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
      t.integer "kind", default: 0, null: false
      t.bigint "reporter_id", null: false
      t.bigint "event_id", null: false
      t.integer "reason", default: 0, null: false
      t.text "description"
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.bigint "admin_user_id"
      t.datetime "take_for_processing_at"
      t.integer "status", default: 0, null: false
      t.index ["event_id"], name: "index_reports_on_event_id"
      t.index ["reporter_id"], name: "index_reports_on_reporter_id"
    end

    create_table "reviews", options: "ENGINE=MyISAM DEFAULT CHARSET=utf8", force: :cascade do |t|
      t.bigint "reviewer_id", null: false
      t.string "assessable_type", null: false
      t.bigint "assessable_id", null: false
      t.decimal "rating", precision: 2, scale: 1, default: "0.0", null: false
      t.integer "reason", default: 0
      t.text "comment"
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.index ["assessable_type", "assessable_id"], name: "index_reviews_on_assessable_type_and_assessable_id"
      t.index ["reviewer_id"], name: "index_reviews_on_reviewer_id"
    end

    create_table "tickets", options: "ENGINE=MyISAM DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
      t.text "name"
      t.integer "ticket_status", limit: 1, default: 0, null: false, comment: "0-created, 2-payment_fail, 3-payment_refunded, 5-refund_need, 8-ticket_payed, 9-ticket_used"
      t.bigint "user_id", null: false
      t.bigint "event_ticket_pack_id", null: false
      t.integer "event_version"
      t.datetime "event_starts_at", null: false
      t.datetime "event_finish_at", null: false
      t.integer "cost_eur_cts", default: 0, null: false
      t.integer "payed_to_owner_eur_cts", default: 0, null: false
      t.integer "for_owner_eur_cts", default: 0, null: false
      t.datetime "ticket_checkout_at"
      t.datetime "ticket_payed_at"
      t.datetime "ticket_used_at"
      t.text "search_text"
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.index ["event_ticket_pack_id"], name: "index_tickets_on_event_ticket_pack_id"
      t.index ["user_id"], name: "index_tickets_on_user_id"
    end

    create_table "tickets_payments", options: "ENGINE=MyISAM DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
      t.bigint "ticket_id", null: false
      t.string "gateway_name", limit: 8, null: false
      t.text "gateway_payment_id"
      t.integer "gateway_payment_need_check", limit: 1, default: 0, null: false
      t.integer "amount_cts", null: false
      t.integer "amount_accepted_cts", default: 0, null: false
      t.integer "amount_refunded_cts", default: 0, null: false
      t.integer "application_fee_amount_cts", default: 0, null: false
      t.string "currency", limit: 16, default: "", null: false
      t.string "card_type", limit: 30, default: ""
      t.string "card_last4", limit: 8, default: ""
      t.string "card_exp_month", limit: 4, default: ""
      t.string "card_exp_year", limit: 8, default: ""
      t.text "request_info_json"
      t.text "response_data_json"
      t.datetime "payment_accepted_at"
      t.datetime "payment_refunded_at"
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.index ["ticket_id"], name: "index_tickets_payments_on_ticket_id"
    end
  end
end
