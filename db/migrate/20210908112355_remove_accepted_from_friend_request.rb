class RemoveAcceptedFromFriendRequest < ActiveRecord::Migration[6.0]
  def change
    remove_column :friend_requests, :accepted, :boolean
  end
end
