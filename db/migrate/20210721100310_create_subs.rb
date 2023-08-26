class CreateSubs < ActiveRecord::Migration[6.0]
  def change
    # add_column :events, :status, :integer, limit: 2, unsigned: true, null: false, default: 0, index: true, comment: '0-created, 1-returned_for_edit, 2-published, 3-have_participants, 4-will_start_soon_with_participants, 5-in_progress_can_connect, 6-in_progress_connection_not_accepted, 8-finished_success_with_payments, 9-finished_success_wo_payments, 10-skip_no_participants, 11-declined_without_participants, 12-declined_with_participants_free, 14-declined_with_participants_payed, 15-fail_with_participants_payed_on_start, 16-fail_with_participants_payed_after_start, 20-end_without_participants'
    # add_column :events, :event_rang_pts, :integer, unsigned: true, null: false, default: 0, index: true
    # add_column :events, :logo_img_index, :integer, unsigned: true, null: false, default: 0
    add_column :subscriptions, :subscription_role, :integer, limit: 2, unsigned: true, null: false, default: 0, index: true, comment: '0-removed_itself, 1-removed_by_manager, 2-monitor, 5-participant, 7-participant_want_pay, 8-participant_can_pay, 9-participant_pay_timeout, 10-participant_pay_in_progress, 11-free_participant, 12-payed_participant, 15-as_manager, 17-as_owner, 20-full_access'
    add_column :subscriptions, :report_text, :text
    add_column :subscriptions, :report_require_admin, :integer, limit: 1, null: false, default: 0
    add_column :subscriptions, :report_admin_text, :text
    add_column :subscriptions, :report_require_refund_tickets, :integer, unsigned: true, null: false, default: 0
    add_column :subscriptions, :report_require_refund_eur, :decimal, precision: 8, scale: 2, null: false, default: 0
    add_column :subscriptions, :report_refunded_tickets, :integer, unsigned: true, null: false, default: 0
    add_column :subscriptions, :report_refunded_eur, :decimal, precision: 8, scale: 2, null: false, default: 0
    add_column :subscriptions, :subscription_payed_tickets, :integer, unsigned: true, null: false, default: 0
    add_column :subscriptions, :subscription_payed_eur, :decimal, precision: 8, scale: 2, null: false, default: 0

    add_index :subscriptions, [:user_id, :event_id], unique: true
  end
end
