class AddUniqueIndexToFriendRequest < ActiveRecord::Migration[6.0]
  def change
    add_index :friend_requests, [:requestor_id, :receiver_id], unique: true
  end
end
