class ChangeEventRatingColumn < ActiveRecord::Migration[6.0]
  def change
    rename_column :events, :event_rating, :rating
    change_column :events, :rating, :decimal, precision: 3, scale: 2
  end
end
