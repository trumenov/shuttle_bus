# frozen_string_literal: true

class TripChatMsgUnread < ApplicationRecord
  belongs_to :trip_chat_msg
  belongs_to :user



end
