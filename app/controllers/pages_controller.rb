# frozen_string_literal: true
require "i18n"

class PagesController < ApplicationController
  # include Accessible
  # respond_to :json
  layout "pages_main.html"
  add_breadcrumb "ShuttleBus", :root_path
  # around_action :skip_bullet

  def main_page
    # render "here!"
  end

  def about
    add_breadcrumb("About", about_path())
  end

  def demo_push
    message = {
      title: "A message!",
      # subject: 'some_my_subject',
      tag: 'notification-tag'
    }
    send_result = Webpush.payload_send(
      message: 'test1',
      # message: JSON.generate(message),
      endpoint: params[:subscription][:endpoint],
      p256dh: params[:subscription][:keys][:p256dh],
      auth: params[:subscription][:keys][:auth],
      ttl: 24 * 60 * 60,
      vapid: {
        subject: 'some_my_subject',
        public_key: Rails.application.secrets.webpush_vapid_public_key.to_s,
        private_key: Rails.application.secrets.webpush_vapid_private_key.to_s
      }
    )
    puts "\n\n\n\n demo_push send_result=[#{ send_result.inspect }] \n\n\n\n"
    render :json => { result: 1 }
  end

  def ticket_transaction_payment_success
    ticket_payment = TicketsPayment.find(Integer(params[:ticket_payment_id]))
    if ticket_payment
      ticket_payment.tpayment_run_check_status_on_bank_side_if_need!
      if current_user && (!(current_user.user_soft_deleted?))
        user_ticket = current_user.tickets.where(id: ticket_payment.ticket_id).first
        if user_ticket
          return success_redirect("Payment success!", profile_my_ticket_path(user_ticket.id))
        else
          # this payment is not owned by authorized user(... What we must do in this case?
        end
      end
    end

  end

  def ticket_transaction_payment_cancel
    ticket_payment = TicketsPayment.find(Integer(params[:ticket_payment_id]))
    if ticket_payment
      ticket_payment.tpayment_run_check_status_on_bank_side_if_need!
      if current_user && (!(current_user.user_soft_deleted?))
        user_ticket = current_user.tickets.where(id: ticket_payment.ticket_id).first
        if user_ticket
          return alert_redirect("Payment fail", profile_my_ticket_path(user_ticket.id))
        else
          # this payment is not owned by authorized user(... What we must do in this case?
        end
      end
    end

  end

  helper_method :get_user_avatar_sm_url
  def get_user_avatar_sm_url(user)
    user.avatar.attached? ? url_for(user.avatar) : ::User.no_profile_avatar_sm_url
  end

  def pub_user_station_sm_img
    img = UserStationImg.find(Integer(params[:simg_id].to_i))
    if img
      if img.image_file.attached?
        processed = ImageProcessing::MiniMagick.source(img.image_file_disk_path).resize_to_limit(90, 90).strip.call
        if processed
          acceptable_types = ["image/jpeg", "image/png"]
          if acceptable_types.include?(MIME::Types.type_for(processed.path).first.content_type)
            contents = processed.read
            File.delete(processed.path) if File.exist?(processed.path)
            response.headers["Cache-Control"] = "public, max-age=#{2.days.to_i}"
            response.headers.delete("Pragma")
            return send_data(contents, :filename => 'sm_' + img.name, :disposition => 'inline')
          else
            img.errors.add(:image_file, 'converted mime_type not allowed')
          end
        else
          img.errors.add(:image_file, 'convert to SM fail')
        end
      else
        img.errors.add(:image_file, 'not_attached')
      end
      return error_response(img.errors.messages, :unprocessable_entity)
    end
    head :not_found
  end

  def pub_vehicle_sm_img
    img = VehicleImg.find(Integer(params[:vimg_id].to_i))
    if img
      if img.image_file.attached?
        processed = ImageProcessing::MiniMagick.source(img.image_file_disk_path).resize_to_limit(140, 140).strip.call
        if processed
          acceptable_types = ["image/jpeg", "image/png"]
          if acceptable_types.include?(MIME::Types.type_for(processed.path).first.content_type)
            contents = processed.read
            File.delete(processed.path) if File.exist?(processed.path)
            response.headers["Cache-Control"] = "public, max-age=#{2.days.to_i}"
            response.headers.delete("Pragma")
            return send_data(contents, :filename => 'sm_' + img.name, :disposition => 'inline')
          else
            img.errors.add(:image_file, 'converted mime_type not allowed')
          end
        else
          img.errors.add(:image_file, 'convert to SM fail')
        end
      else
        img.errors.add(:image_file, 'not_attached')
      end
      return error_response(img.errors.messages, :unprocessable_entity)
    end
    head :not_found
  end
end
