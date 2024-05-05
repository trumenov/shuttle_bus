# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2024_05_05_133842) do

  create_table "active_admin_comments", charset: "utf8mb4", options: "ENGINE=MyISAM", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type", limit: 50
    t.bigint "resource_id"
    t.string "author_type", limit: 50
    t.bigint "author_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace", length: 20
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "active_storage_attachments", charset: "utf8mb4", options: "ENGINE=MyISAM", force: :cascade do |t|
    t.string "name", limit: 140, null: false
    t.string "record_type", limit: 50, null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", options: "ENGINE=MyISAM", force: :cascade do |t|
    t.string "key", limit: 30, null: false
    t.string "filename", limit: 200, null: false
    t.string "content_type", limit: 50
    t.string "service_name", limit: 150, null: false
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", limit: 50, null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "admin_users", charset: "utf8mb4", options: "ENGINE=MyISAM", force: :cascade do |t|
    t.string "email", limit: 80, default: "", null: false
    t.string "encrypted_password", limit: 200, default: "", null: false
    t.text "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", length: 10
  end

  create_table "ceparser_tasks", id: { type: :integer, unsigned: true }, charset: "utf8", options: "ENGINE=MyISAM", force: :cascade do |t|
    t.bigint "task_queue_id", default: 0, null: false, unsigned: true
    t.integer "prio", default: 0, null: false, unsigned: true
    t.text "task_options_json", size: :long
    t.bigint "take_await_seconds", default: 0, null: false, unsigned: true
    t.bigint "take_max_seconds", default: 0, null: false, unsigned: true
    t.integer "failed_cnt", default: 0, null: false, unsigned: true
    t.string "taked_by"
    t.datetime "taked_at"
    t.datetime "last_ping_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["task_queue_id", "prio"], name: "index_ceparser_task_on_queue_prio"
  end

  create_table "task_queues", id: { type: :integer, unsigned: true }, charset: "utf8", options: "ENGINE=MyISAM", force: :cascade do |t|
    t.string "name", limit: 240, default: "", null: false
    t.bigint "user_id", default: 0, null: false, unsigned: true
    t.string "pub_password"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_task_queues_on_user_id"
  end

  create_table "ticket_payments", id: { type: :integer, unsigned: true }, charset: "utf8mb4", options: "ENGINE=MyISAM", force: :cascade do |t|
    t.bigint "ticket_id", null: false, unsigned: true
    t.string "gateway_name", limit: 8, null: false
    t.text "gateway_payment_id"
    t.integer "gateway_payment_need_check", limit: 1, default: 0, null: false, unsigned: true
    t.integer "amount_pts_cts", null: false, unsigned: true
    t.integer "amount_accepted_pts_cts", default: 0, null: false, unsigned: true
    t.integer "amount_refunded_pts_cts", default: 0, null: false, unsigned: true
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
    t.index ["ticket_id"], name: "index_ticket_payments_on_ticket_id"
  end

  create_table "tickets", id: { type: :integer, unsigned: true }, charset: "utf8mb4", options: "ENGINE=MyISAM", force: :cascade do |t|
    t.text "name"
    t.integer "slot_status", limit: 1, default: 0, null: false, comment: "created: 0, slot_fail: 1, slot_canceled: 3, slot_declined: 5, slot_asked: 8, slot_accepted: 10, slot_taked: 20", unsigned: true
    t.bigint "user_id", null: false, unsigned: true
    t.bigint "trip_ticket_pack_id", null: false, unsigned: true
    t.integer "cost_pts_cts", default: 0, null: false, unsigned: true
    t.integer "payed_pts_cts", default: 0, null: false, unsigned: true
    t.integer "payed_to_owner_pts_cts", default: 0, null: false, unsigned: true
    t.datetime "ticket_checkout_at"
    t.datetime "ticket_payed_at"
    t.datetime "ticket_refunded_at"
    t.datetime "ticket_used_at"
    t.text "ticket_on_payed_info_json"
    t.text "search_text"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["trip_ticket_pack_id"], name: "index_tickets_on_trip_ticket_pack_id"
    t.index ["user_id"], name: "index_tickets_on_user_id"
  end

  create_table "trip_chat_msg_unreads", id: { type: :integer, unsigned: true }, charset: "utf8mb4", options: "ENGINE=MyISAM", force: :cascade do |t|
    t.bigint "trip_chat_msg_id", null: false, unsigned: true
    t.bigint "user_id", null: false, unsigned: true
    t.index ["trip_chat_msg_id"], name: "index_trip_chat_msg_unreads_on_trip_chat_msg_id"
    t.index ["user_id"], name: "index_trip_chat_msg_unreads_on_user_id"
  end

  create_table "trip_chat_msgs", id: { type: :integer, unsigned: true }, charset: "utf8mb4", options: "ENGINE=MyISAM", force: :cascade do |t|
    t.bigint "trip_id", null: false, unsigned: true
    t.bigint "user_id", null: false, unsigned: true
    t.text "msg_html"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["trip_id"], name: "index_trip_chat_msgs_on_trip_id"
    t.index ["user_id"], name: "index_trip_chat_msgs_on_user_id"
  end

  create_table "trip_ticket_packs", id: { type: :integer, unsigned: true }, charset: "utf8mb4", options: "ENGINE=MyISAM", force: :cascade do |t|
    t.text "name"
    t.bigint "trip_id", null: false, unsigned: true
    t.integer "pack_capacity", default: 0, null: false, unsigned: true
    t.integer "tickets_sold_cnt", default: 0, null: false, unsigned: true
    t.integer "tickets_pay_fail_cnt", default: 0, null: false, unsigned: true
    t.integer "ticket_cost_pts_cts", default: 0, null: false, unsigned: true
    t.integer "ticket_cost_currency", limit: 1, default: 0, null: false, comment: "0-NONE, 1-USD, 2-EUR", unsigned: true
    t.integer "trip_ticket_pack_sale_rule", limit: 1, default: 0, null: false, comment: "0-stopped_sale, 1-simple_sale, 2-with_confirmation"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["trip_id"], name: "index_trip_ticket_packs_on_trip_id"
  end

  create_table "trips", id: { type: :integer, unsigned: true }, charset: "utf8mb4", options: "ENGINE=MyISAM", force: :cascade do |t|
    t.bigint "vehicle_id", null: false, unsigned: true
    t.bigint "user_route_id", null: false, unsigned: true
    t.bigint "starts_at_unix", default: 0, null: false, unsigned: true
    t.integer "published", limit: 1, default: 0, null: false, unsigned: true
    t.integer "all_trip_tickets_cnt", default: 0, null: false, unsigned: true
    t.text "search_text"
    t.datetime "deleted_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_route_id"], name: "index_trips_on_user_route_id"
    t.index ["vehicle_id"], name: "index_trips_on_vehicle_id"
  end

  create_table "user_notifications", charset: "utf8mb4", options: "ENGINE=MyISAM", force: :cascade do |t|
    t.bigint "user_id"
    t.text "notification_msg_text"
    t.text "notification_data_json", size: :long, collation: "utf8mb4_bin"
    t.datetime "sended_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_user_notifications_on_user_id"
  end

  create_table "user_push_subscriptions", charset: "utf8mb4", options: "ENGINE=MyISAM", force: :cascade do |t|
    t.bigint "user_id"
    t.text "push_subscription_data_json", size: :long
    t.datetime "last_success_sended_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_user_push_subscriptions_on_user_id"
  end

  create_table "user_route_points", id: { type: :integer, unsigned: true }, charset: "utf8mb4", options: "ENGINE=MyISAM", force: :cascade do |t|
    t.bigint "user_route_id", null: false, unsigned: true
    t.bigint "user_station_id", null: false, unsigned: true
    t.integer "after_start_planned_seconds", default: 0, null: false, unsigned: true
    t.integer "station_stay_seconds", default: 0, null: false, unsigned: true
    t.integer "tickets_cnt", default: 0, null: false, unsigned: true
    t.datetime "deleted_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_route_id"], name: "index_user_route_points_on_user_route_id"
    t.index ["user_station_id"], name: "index_user_route_points_on_user_station_id"
  end

  create_table "user_routes", id: { type: :integer, unsigned: true }, charset: "utf8mb4", options: "ENGINE=MyISAM", force: :cascade do |t|
    t.string "name", limit: 240, default: "", null: false
    t.bigint "user_id", null: false, unsigned: true
    t.text "route_description_text"
    t.text "route_props_text"
    t.datetime "deleted_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_user_routes_on_user_id"
  end

  create_table "user_station_imgs", id: { type: :integer, unsigned: true }, charset: "utf8mb4", options: "ENGINE=MyISAM", force: :cascade do |t|
    t.bigint "user_station_id", null: false, unsigned: true
    t.integer "prio", default: 0, null: false, unsigned: true
    t.text "name"
    t.datetime "deleted_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_station_id"], name: "index_user_station_imgs_on_user_station_id"
  end

  create_table "user_stations", id: { type: :integer, unsigned: true }, charset: "utf8", options: "ENGINE=MyISAM", force: :cascade do |t|
    t.string "name", limit: 240, default: "", null: false
    t.bigint "user_id", null: false, unsigned: true
    t.text "station_description_text"
    t.text "station_props_text"
    t.integer "station_lat", default: 0, null: false
    t.integer "station_lng", default: 0, null: false
    t.float "station_lat_f64", limit: 53, default: 0.0, null: false
    t.float "station_lng_f64", limit: 53, default: 0.0, null: false
    t.datetime "deleted_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_user_stations_on_user_id"
  end

  create_table "users", charset: "utf8mb4", options: "ENGINE=MyISAM", force: :cascade do |t|
    t.text "name"
    t.string "email", limit: 150, default: "", null: false
    t.text "last_name"
    t.text "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "password_changed_at"
    t.text "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.text "bio"
    t.text "phone"
    t.text "gender"
    t.text "facebook_link"
    t.text "instagram_link"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "deleted_at"
    t.text "deleted_with_email"
    t.integer "current_password_unknown", limit: 1, default: 0, null: false
    t.string "encrypted_password", limit: 250, default: "", null: false
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.text "current_sign_in_ip"
    t.text "last_sign_in_ip"
    t.text "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.text "unlock_token"
    t.datetime "locked_at"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", length: 8
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", length: 8
    t.index ["unlock_token"], name: "index_users_on_unlock_token", length: 8
  end

  create_table "vehicle_imgs", id: { type: :integer, unsigned: true }, charset: "utf8mb4", options: "ENGINE=MyISAM", force: :cascade do |t|
    t.bigint "vehicle_id", null: false, unsigned: true
    t.integer "prio", default: 0, null: false, unsigned: true
    t.text "name"
    t.datetime "deleted_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["vehicle_id"], name: "index_vehicle_imgs_on_vehicle_id"
  end

  create_table "vehicles", id: { type: :integer, unsigned: true }, charset: "utf8", options: "ENGINE=MyISAM", force: :cascade do |t|
    t.string "name", limit: 240, default: "", null: false
    t.bigint "user_id", null: false, unsigned: true
    t.integer "vehicle_seats_cnt", default: 0, null: false, unsigned: true
    t.text "vehicle_description_text"
    t.text "vehicle_props_text"
    t.datetime "deleted_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_vehicles_on_user_id"
  end

end
