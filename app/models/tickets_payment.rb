# frozen_string_literal: true

class TicketsPayment < ApplicationRecord
  belongs_to :ticket
  scope :waiting_bank_result, ->() { where(gateway_payment_need_check: 1).where.not(gateway_payment_id: nil) }
  scope :updated_at_minimum_seconds_ago, ->(secs) { where(updated_at: ..(Time.now().localtime - secs.seconds)) }
# class TicketPayment < Pay::Charge

  # def receipts
    # do some receipts stuff using the https://github.com/excid3/receipts gem
  #   puts "\n\n\n\n receipts started. \n\n\n\n\n"
  #   Receipts::Receipt.new(id: id,
  #                         subheading: "RECEIPT FOR CHARGE #%{id}",
  #                         product: "GoRails",
  #                         line_items: [
  #                           ["Date",           created_at.to_s],
  #                           ["Product",        "GoRails"],
  #                           ["Charged to",     "#{card_type} (**** **** **** #{card_last4})"],
  #                           ["Transaction ID", id]
  #                         ])
  # end
  after_save :refill_ticket_payed_at


  # def card_number; ""; end
  # def card_verification; ""; end
  def refill_ticket_payed_at; ticket.refill_payed_at!; end
  def response_data_arr; response_data_json.to_s.to_json_arr; end
  def payment_transaction_in_progress?; gateway_payment_need_check.positive? && gateway_payment_id.to_s.size_positive?; end

  def try_get_checkout_url; tpayment_run_check_status_on_bank_side_if_need!.to_s; end
  def tpayment_run_check_status_on_bank_side_if_need!(reject_payment_if_not_done = false)
    checkout_url = nil
    if gateway_payment_need_check.positive?
      ret_data = Stripe::Checkout::Session.retrieve(gateway_payment_id)
      arr = response_data_arr
      arr.push(ret_data)
      # puts "\n\n\n\n ret_data=[#{ ret_data.to_json }] \n\n\n\n"
      if ret_data.id.str_eq?(gateway_payment_id)
        if ret_data.payment_status.str_eq?("paid")
          update!(amount_accepted_cts: ret_data.amount_total.to_s.to_i || 0, gateway_payment_need_check: 0, response_data_json: arr.to_json)
        elsif ret_data.payment_status.str_eq?("unpaid")
          if ret_data.payment_intent.to_s.size_positive?
            # puts "\n\n\n\n refresh unpaid[#{ ret_data.payment_intent.to_s }] in ret_data_status=[#{ ret_data.payment_status }] \n\n\n\n"
            fresh_intent = Stripe::PaymentIntent.retrieve(ret_data.payment_intent.to_s)
            arr.push(fresh_intent)
            # puts "\n\n\n\nfresh_intent=[#{ fresh_intent.to_json }] \n\n\n\n"
            if fresh_intent.status.str_eq?("canceled")
              update!(gateway_payment_need_check: 0, response_data_json: arr.to_json)
              ticket.trip_ticket_pack.release_ticket_slot!
            else
              if reject_payment_if_not_done
                canceled_intent = Stripe::PaymentIntent.cancel(ret_data.payment_intent.to_s)
                # puts "\n\n\n\n canceled_intent=[#{ canceled_intent.to_json }] \n\n\n\n"
                arr.push(canceled_intent)
                # raise("TMP STOP 234243432.")
                update!(gateway_payment_need_check: 0, response_data_json: arr.to_json)
                ticket.trip_ticket_pack.release_ticket_slot!
              else
                checkout_url = ret_data.url
                # puts "\n\n\n\n TMP STOP 234321132. checkout_url=[#{ checkout_url }] \n\n\n fresh_intent=[#{ fresh_intent.inspect }] \n\n\n\n"
              end
            end
          end
        else
          update!(gateway_payment_need_check: 0, response_data_json: arr.to_json)
          ticket.trip_ticket_pack.release_ticket_slot!
        end
      end
    end
    checkout_url
  end

  def calc_refund_amount_cts
    return 0 if amount_refunded_cts.positive?
    amount_accepted_cts - amount_refunded_cts
  end

  def try_refund_ticket_payment!
    refund_amount_cts = calc_refund_amount_cts
    if refund_amount_cts.positive?
      ret_data = Stripe::Checkout::Session.retrieve(gateway_payment_id)
      # puts "\n\n\n\n try_refund_ticket_payment ret_data=[#{ ret_data.to_json }] \n\n\n\n"
      if ret_data.id.str_eq?(gateway_payment_id)
        payment_intent = ret_data.payment_intent.to_s
        max_ret_val = (ret_data.amount_total.to_s.to_i || 0)
        if max_ret_val.positive? && (max_ret_val >= refund_amount_cts)
          refund_data = Stripe::Refund.create({
            amount: refund_amount_cts,
            payment_intent: payment_intent,
          })
          # puts "\n\n\n\n try_refund_ticket_payment refund_data=[#{ refund_data.to_json }] \n\n\n\n"
          if refund_data.status.to_s.str_eq?("succeeded")
            # puts "\n\n\n\n\n refund succeeded!!! \n\n\n\n"
            update!(amount_refunded_cts: refund_amount_cts)
            ticket.update!(slot_status: :slot_canceled)
            ticket.trip_ticket_pack.release_ticket_slot!
            return true
          else
            update!(response_data_json: response_data_arr.push(ret_data).to_json)
            @errors.add(:refund, "Wrong refund status[#{ refund_data.status.to_s }]")
          end
          # raise("TMP STOP 234123123312. asdasd")
        end
      end
    end
    false
  end

  def self.run_fill_payments
    # puts "\n\n\n\n TMP STOP 3423423432. run_fill_payments started \n\n\n\n"
    seconds_for_check = Rails.env.development? ? 15 : 300
    waiting_bank_result.updated_at_minimum_seconds_ago(seconds_for_check).each do |x|
      # puts "\n\n\n run check tpayment[#{ x.id }] \n\n\n"
      x.tpayment_run_check_status_on_bank_side_if_need!
      # puts "\n\n\n end check tpayment[#{ x.id }] \n\n\n"
    end

    seconds_for_payment_timeout = Rails.env.development? ? 40 : 450
    waiting_bank_result.updated_at_minimum_seconds_ago(seconds_for_payment_timeout).each do |x|
      # puts "\n\n\n run check tpayment[#{ x.id }] \n\n\n"
      x.tpayment_run_check_status_on_bank_side_if_need!(true)
      x.update!(updated_at: Time.now().localtime)
      # puts "\n\n\n end check tpayment[#{ x.id }] \n\n\n"
    end
    true
  end

end
