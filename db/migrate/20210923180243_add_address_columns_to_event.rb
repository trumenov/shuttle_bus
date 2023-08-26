class AddAddressColumnsToEvent < ActiveRecord::Migration[6.0]
  def change
    add_column :events, :geography, :json
    add_index :events, [:latitude, :longitude]
  end
end
