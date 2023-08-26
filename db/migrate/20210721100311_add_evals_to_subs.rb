class AddEvalsToSubs < ActiveRecord::Migration[6.0]
  def change
    # add_column :events, :status, :integer, limit: 2, unsigned: true, null: false, default: 0, index: true, comment: '0-created, 1-returned_for_edit, 2-published, 3-have_participants, 4-will_start_soon_with_participants, 5-in_progress_can_connect, 6-in_progress_connection_not_accepted, 8-finished_success_with_payments, 9-finished_success_wo_payments, 10-skip_no_participants, 11-declined_without_participants, 12-declined_with_participants_free, 14-declined_with_participants_payed, 15-fail_with_participants_payed_on_start, 16-fail_with_participants_payed_after_start, 20-end_without_participants'
    # add_column :events, :event_rang_pts, :integer, unsigned: true, null: false, default: 0, index: true
    # add_column :events, :logo_img_index, :integer, unsigned: true, null: false, default: 0
    add_column :subscriptions, :event_evaluation, :integer, limit: 1, unsigned: true, null: false, default: 0
    add_column :events, :event_rating, :integer, after: :status, limit: 1, unsigned: true, null: false, default: 0

  end
end
