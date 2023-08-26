class AddFieldsForReport < ActiveRecord::Migration[6.0]
  def change
    add_column :reports, :admin_user_id, :bigint
    add_column :reports, :take_for_processing_at, :datetime
    add_column :reports, :status, :integer, default: 0, null: false
  end
end
