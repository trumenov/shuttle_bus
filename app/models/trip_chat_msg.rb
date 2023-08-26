# frozen_string_literal: true

class TripChatMsg < ApplicationRecord
  belongs_to :trip
  belongs_to :user
  # has_many :trip_chat_msg_unreads, dependent: :destroy

  after_create :add_unreads_to_all_trip_users


  def add_unreads_to_all_trip_users
    trip.trip_users_with_ticket.each do |tuser|
      tuser.trip_chat_msg_unreads.create!(trip_chat_msg_id: id)
    end
  end

  def msg_text_html; msg_html.to_s; end

  def self.pack_by_src_ca_name_trip_chat_msgs(msgs_in, current_user_id)
    # result = [] of NamedTuple(ca_name: String, ca_id: Int32, src_ca_ind: Int32, msgs_arr: Array(ClientQuestionsMsg))
    result = []
    last_name = ""
    full_name = ""
    detected_names = [""]
    last_ca_id = 0
    # last_arr : Array(ClientQuestionsMsg) = [] of ClientQuestionsMsg
    last_arr = []
    msgs_in.sort_by(&:id).each do |msg|
      src_ca_full_name = "#{ msg.user_id }_#{ msg.user.name_or_email_for_public }"
      unless src_ca_full_name.str_eq?(full_name)
        if last_arr.any?
          detected_names.push(full_name) unless detected_names.include?(full_name)
          # src_ca_ind = detected_names.index(full_name)
          src_ca_ind = last_ca_id.eql?(current_user_id) ? 1 : 0
          result.push({ ca_name: last_name, ca_id: last_ca_id, src_ca_ind: src_ca_ind, msgs_arr: last_arr })
          last_arr = []
        end
        last_name = msg.user.name_or_email_for_public
        full_name = src_ca_full_name
        last_ca_id = msg.user_id
      end
      last_arr.push(msg)
    end
    if last_arr.any?
      detected_names.push(full_name) unless detected_names.include?(full_name)
      # src_ca_ind = detected_names.index(full_name)
      src_ca_ind = last_ca_id.eql?(current_user_id) ? 1 : 0
      result.push({ ca_name: last_name, ca_id: last_ca_id, src_ca_ind: src_ca_ind, msgs_arr: last_arr })
    end
    result
  end
end
