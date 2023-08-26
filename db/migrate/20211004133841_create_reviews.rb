class CreateReviews < ActiveRecord::Migration[6.0]
  def change
    create_table :reviews, { options: "ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" } do |t|
      t.references :reviewer, null: false, foreign_key: true, index: true
      t.references :assessable, polymorphic: true, null: false, index: true
      t.decimal :rating, null: false, precision: 2, scale: 1, default: 0.0
      t.integer :reason, default: 0
      t.text :comment

      t.timestamps
    end
  end
end
