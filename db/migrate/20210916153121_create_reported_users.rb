class CreateReportedUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :reported_users, { options: "ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci" } do |t|
      t.references :report, null: false, foreign_key: true, index: true
      t.references :user, null: false, foreign_key: true, index: true
      t.timestamps
    end

    add_index :reported_users, [:report_id, :user_id], unique: true
  end
end
