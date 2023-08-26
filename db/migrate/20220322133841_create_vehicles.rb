class CreateVehicles < ActiveRecord::Migration[6.0]
  def change
    create_table :vehicles, { id: :unsigned_integer, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" } do |t|
      t.string :name, null: false, default: "", limit: 240
      t.references :user, foreign_key: true, null: false, index: true, :unsigned => true
      t.integer :vehicle_seats_cnt, limit: 4, null: false, default: 0, :unsigned => true
      t.text :vehicle_description_text
      t.text :vehicle_props_text
      t.datetime :deleted_at
      t.timestamps null: false
    end

    create_table :vehicle_imgs, { id: :unsigned_integer, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci" } do |t|
      t.references :vehicle, null: false, foreign_key: true, index: true, :unsigned => true
      t.integer :prio, limit: 4, null: false, default: 0, :unsigned => true
      t.text :name
      t.datetime :deleted_at
      t.timestamps null: false
    end

    create_table :user_stations, { id: :unsigned_integer, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" } do |t|
      t.string :name, null: false, default: "", limit: 240
      t.references :user, foreign_key: true, null: false, index: true, :unsigned => true
      t.text :station_description_text
      t.text :station_props_text
      t.integer :station_lat, limit: 4, null: false, default: 0
      t.integer :station_lng, limit: 4, null: false, default: 0
      t.column :station_lat_f64, "double(18,15)", null: false, default: 0
      t.column :station_lng_f64, "double(18,15)", null: false, default: 0
      t.datetime :deleted_at
      t.timestamps null: false
    end

    create_table :user_station_imgs, { id: :unsigned_integer, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci" } do |t|
      t.references :user_station, null: false, foreign_key: true, index: true, :unsigned => true
      t.integer :prio, limit: 4, null: false, default: 0, :unsigned => true
      t.text :name
      t.datetime :deleted_at
      t.timestamps null: false
    end

    create_table :user_routes, { id: :unsigned_integer, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci" } do |t|
      t.string :name, null: false, default: "", limit: 240
      t.references :user, foreign_key: true, null: false, index: true, :unsigned => true
      t.text :route_description_text
      t.text :route_props_text
      t.datetime :deleted_at
      t.timestamps null: false
    end

    create_table :user_route_points, { id: :unsigned_integer, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci" } do |t|
      t.references :user_route, null: false, foreign_key: true, index: true, :unsigned => true
      t.references :user_station, null: false, foreign_key: true, index: true, :unsigned => true
      t.integer :after_start_planned_seconds, limit: 4, null: false, default: 0, :unsigned => true
      t.integer :station_stay_seconds, limit: 4, null: false, default: 0, :unsigned => true
      t.integer :tickets_cnt, limit: 4, null: false, default: 0, :unsigned => true
      t.datetime :deleted_at
      t.timestamps null: false
    end

    create_table :trips, { id: :unsigned_integer, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci" } do |t|
      t.references :vehicle   , null: false, foreign_key: true, index: true, :unsigned => true
      t.references :user_route, null: false, foreign_key: true, index: true, :unsigned => true
      t.bigint :starts_at_unix, null: false, default: 0, :unsigned => true
      t.integer :published, limit: 1, null: false, default: 0, :unsigned => true
      t.integer :all_trip_tickets_cnt, limit: 4, null: false, default: 0, :unsigned => true
      t.text :search_text
      t.datetime :deleted_at
      t.timestamps null: false
    end

    create_table :trip_chat_msgs, { id: :unsigned_integer, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci" } do |t|
      t.references :trip, null: false, foreign_key: true, index: true, :unsigned => true
      t.references :user, null: false, foreign_key: true, index: true, :unsigned => true
      t.text :msg_html
      t.timestamps null: false
    end

    create_table :trip_chat_msg_unreads, { id: :unsigned_integer, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci" } do |t|
      t.references :trip_chat_msg, null: false, foreign_key: true, index: true, :unsigned => true
      t.references :user         , null: false, foreign_key: true, index: true, :unsigned => true
    end
  end
end
