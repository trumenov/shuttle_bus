class AddUserToEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :events, { options: "ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci" } do |t|
      t.text :name
      t.references :user, foreign_key: true, null: false, index: true
      t.text :description
      t.text :house_rules
      t.text :address
      t.decimal :latitude , precision: 11, scale: 8
      t.decimal :longitude, precision: 11, scale: 8
      t.datetime :event_start_time, null: true, default: nil
      t.integer :number_of_participants_max, null: false, default: 0
      t.integer :event_duration_seconds_max, null: false, default: 0
      t.decimal :price_eur, precision: 8, scale: 2
      t.decimal :place_square_meters, precision: 10, scale: 2
      t.datetime :declined_at, null: true, default: nil

      t.text :search_text
      t.timestamps
    end

    create_table :subscriptions, { options: "ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci" } do |t|
      t.text :user_name
      t.text :user_email
      t.references :event, foreign_key: true, index: true
      t.references :user, foreign_key: true, index: true
      t.timestamps
    end
  end
end
