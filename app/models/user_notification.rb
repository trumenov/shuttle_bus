# frozen_string_literal: true

class UserNotification < ApplicationRecord
  belongs_to :user
  # serialize :push_subscription_data_json, Hash
  def notification_push_url; notification_data_json ? notification_data_json.to_h["url"].to_s : ""; end

  def notification_run_send!
    UserNotificationMailer.with(user: user, notification: self, url: notification_push_url).default_notification_email.deliver_now
    user.user_push_subscriptions.each do |usub|
      usub.send_message(notification_msg_text.to_s, notification_push_url, id || 0)
    end
    update!(sended_at: Time.now().localtime)
    true
  end

end
