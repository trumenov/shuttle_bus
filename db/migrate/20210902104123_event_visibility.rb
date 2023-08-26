class EventVisibility < ActiveRecord::Migration[6.0]
  def self.up
    add_column :events, :visibility_status, :integer, after: :status, null: false, default: 0, limit: 1
    add_index :events, :visibility_status

    create_table :event_imgs, { options: "ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci" } do |t|
      t.references :event, null: false, foreign_key: true, index: true
      t.integer :prio, null: false, default: 0
      t.text :name
      t.datetime :deleted_at
      t.timestamps null: false
    end

    remove_column :events, :logo_img_index
  end

  def self.down
    add_column :events, :logo_img_index, :integer, after: :event_rang_pts, null: false, default: 0
    remove_column :events, :visibility_status
    drop_table :event_imgs
  end
end
