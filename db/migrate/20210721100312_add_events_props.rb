class AddEventsProps < ActiveRecord::Migration[6.0]
  def change
    create_table :event_props, { options: "ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci" } do |t|
      t.text :name
      t.references :event, foreign_key: true, null: false
      t.integer :pos_id, null: false, default: 0, limit: 4, unsigned: true
      t.bigint :full_sum, null: false, default: 0, :unsigned => true
      t.string :prop_pref, null: false, limit: 1, default: 'N'
      t.text :prop_name
      t.bigint :prop_name_sum, null: false, default: 0, :unsigned => true, index: true
      t.text :prop_val
      t.bigint :prop_val_sum, null: false, default: 0, :unsigned => true, index: true
      t.timestamps
    end

    create_table :events_filter_fields, { options: "ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci" } do |t|
      t.text :name
      t.integer :show_for_client, null: false, default: 0, limit: 1, unsigned: true
      t.bigint :eff_name_sum, null: false, default: 0, :unsigned => true
      t.integer :prio, null: false, default: 0, limit: 4, unsigned: true
      t.timestamps
    end

    reversible do |dir|
      dir.up do
        change_column :event_props, :prop_pref, "VARCHAR(1) CHARACTER SET cp1251 COLLATE cp1251_general_ci NOT NULL DEFAULT 'N'"
        add_index :event_props, [:event_id, :pos_id], unique: true
      end
    end
  end
end
