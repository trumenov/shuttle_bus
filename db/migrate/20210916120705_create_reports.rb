class CreateReports < ActiveRecord::Migration[6.0]
  def change
    create_table :reports, { options: "ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci" } do |t|
      t.integer :kind, null: false, default: 0
      t.references :reporter, references: :users, foreign_key: { to_table: :users }, index: true, null: false
      t.references :event, null: false, foreign_key: true, index: true
      t.integer :reason, null: false, default: 0
      t.text :description

      t.timestamps
    end
  end
end
