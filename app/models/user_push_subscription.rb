# frozen_string_literal: true

class UserPushSubscription < ApplicationRecord
  belongs_to :user
  # serialize :push_subscription_data_json, Hash
  def push_subscription_data_h; push_subscription_data_json.to_json_h; end
  def webpush_key_auth; push_subscription_data_h.to_h["keys"]["auth"].to_s; end


  def self.gen_dst_url_for_notification(url = "")
    dst = "#{ Rails.application.secrets.default_url_options[:host] }:#{ Rails.application.secrets.default_url_options[:port] }"
    if url.size_positive?
      unless ((url.starts_with?('http') || url.starts_with?('//')))
        url = dst + url
      end
    else
      url = "#{ dst }/profile/my_notifications"
    end
    url
  end

  def send_message(msg, url = '', notification_id = 0)
    notification_id = 0 unless notification_id.positive?
    url = self.class.gen_dst_url_for_notification(url)
    vapid = { subject: 'some_subject',
              public_key: Rails.application.secrets.webpush_vapid_public_key.to_s,
              private_key: Rails.application.secrets.webpush_vapid_private_key.to_s
            }
    attrs = { message: { title: 'ShuttleBus notification', body: msg, url: url, id: notification_id }.to_json,
              # message: JSON.generate(message),
              endpoint: push_subscription_data_h.to_h["endpoint"].to_s,
              p256dh: push_subscription_data_h.to_h["keys"]["p256dh"].to_s,
              auth: push_subscription_data_h.to_h["keys"]["auth"].to_s,
              ttl: 24 * 60 * 60
            }
    send_result = Webpush.payload_send(attrs.merge({ vapid: vapid }))
    # puts "\n\n\n send_result[#{ send_result.code }] attrs=[#{ attrs.to_json }] \n\n\n\n"
    if (send_result.code.to_i || 0).in?([200, 201])
      update!(last_success_sended_at: Time.now().localtime)
      return true
    end
    return false
  end
end
