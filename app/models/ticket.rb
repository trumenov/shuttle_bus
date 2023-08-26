# frozen_string_literal: true

class Ticket < ApplicationRecord
  belongs_to :trip_ticket_pack
  belongs_to :user
  has_many :ticket_payments
  # has_one :trip,  through: :trip_ticket_pack

  scope :successfully_payed, ->() { where.not(ticket_payed_at: nil) }

  scope :for_trip, ->(trip) { where(trip_ticket_pack: trip.trip_ticket_packs) }
  scope :for_trips_scope, ->(trips_scope) { where(trip_ticket_pack: TripTicketPack.by_trips(trips_scope)) }

  def slot_status_id; self.class.slot_statuses[slot_status]; end
  enum slot_status: { created: 0, slot_fail: 1, slot_canceled: 3, slot_declined: 5, slot_asked: 8,
                        slot_accepted: 10, slot_taked: 20 }, _prefix: true

  def accepted_not_refuneded_payments; ticket_payments.select { |x| x.amount_accepted_cts.positive? && x.amount_refunded_cts.zero? }; end
  def ticket_refund_sum_cts; ticket_payments.reduce(0) { |r, x| r += x.amount_refunded_cts }; end
  def ticket_accepted_sum_cts; ticket_payments.reduce(0) { |r, x| r += x.amount_accepted_cts }; end
  def ticket_payed_sum_cts; ticket_accepted_sum_cts - ticket_refund_sum_cts; end
  def ticket_fully_payed?; ticket_payed_sum_cts >= cost_pts_cts; end
  def ticket_can_be_refunded?; accepted_not_refuneded_payments.any?; end
  def current_ticket_cost_pts; (cost_pts_cts / 100.0); end

  def ticket_need_slotting?
    unless ticket_fully_payed?
      if trip_ticket_pack.trip_ticket_pack_sale_rule_with_confirmation?
        if slot_status.in? %w{slot_accepted}
          return true
        end
      else
        if slot_status.in? %w{created slot_canceled slot_declined slot_asked slot_accepted}
          return true
        end
      end
    end
    false
  end

  def ticket_need_payment?
    unless ticket_fully_payed?
      if trip_ticket_pack.trip_ticket_pack_sale_rule_with_confirmation?
        if slot_status.in? %w{slot_accepted slot_taked}
          return true
        end
      else
        if slot_status.in? %w{created slot_canceled slot_declined slot_asked slot_accepted slot_taked}
          return true
        end
      end
    end
    false
  end

  def can_user_try_to_pay_ticket?
    unless ticket_fully_payed?
      return false if ticket_payments.find { |x| x.payment_transaction_in_progress? }
      if trip_ticket_pack.trip_ticket_pack_sale_rule_with_confirmation?
        if slot_status.in? %w{slot_accepted slot_taked}
          return true
        end
      else
        if slot_status.in? %w{created slot_canceled slot_declined slot_asked slot_accepted slot_taked}
          return true
        end
      end
    end
    false
  end

  def ticket_payment_fail?
    unless ticket_fully_payed?
      return true if ticket_payments.any? && (!(ticket_payments.select { |x| x.payment_transaction_in_progress? }))
    end
    false
  end

  def ticket_allow_user_to_see_chat?; ticket_fully_payed?; end
  def ticket_payment_refunded?; ticket_payments.find { |x| x.amount_refunded_cts.positive? } ? true : false; end

  def try_take_slot_in_tpack!
    if id.positive? && trip_ticket_pack.id.positive?
      return true if slot_status_slot_taked?
      if trip_ticket_pack.tpack_can_try_give_a_slot?
        can_try_get_slot = false
        if slot_status_created?
          if trip_ticket_pack.trip_ticket_pack_sale_rule_with_confirmation?
            update!(slot_status: :slot_asked)
            return false
          else
            can_try_get_slot = true
          end
        elsif slot_status_slot_canceled?
          can_try_get_slot = true
        elsif slot_status_slot_accepted?
          can_try_get_slot = true
        end
        if can_try_get_slot
          if trip_ticket_pack.success_placed_ticket_slot_in_tpack_by_sqls?
            update!(slot_status: :slot_taked)
            return true
          else
            update!(slot_status: :slot_fail)
          end
        end
      end
    end
    false
  end

  def client_ticket_name_html; "<span class='ticket_name'>Ticket \##{ id.to_s }</span>".html_safe; end
  def client_slot_status_html
    s = { n: slot_status.to_s, s: 'color: black' }
    s = { n: "Ticket payed!", s: 'color: green' } if ticket_fully_payed?
    s = { n: "Ticket need payments", s: 'color: orange' } if ticket_need_payment?
    s = { n: "Ticket payment fail", s: 'color: red' } if ticket_payment_fail?
    s = { n: "Ticket payment refunded", s: 'color: red' } if ticket_payment_refunded?
    "<span class='slot_status' style='#{ s[:s].ehtml };'>#{ s[:n].ehtml }</span>".html_safe
  end

  def refill_payed_at!
    have_changes = false
    if accepted_not_refuneded_payments.any?
      unless ticket_payed_at
        update!(ticket_payed_at: accepted_not_refuneded_payments.last.updated_at)
        have_changes = true
      end
    else
      if ticket_payed_at
        update!(ticket_payed_at: nil)
        have_changes = true
      end
    end
    trip_ticket_pack.recalc_tickets_sold_cnt! if have_changes
    true
  end

end
