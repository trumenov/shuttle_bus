class Profile::SoldTickets::SoldTicketsController < Profile::SoldTickets::SoldTicketsBaseController
  skip_before_action :set_current_sold_ticket, only: %w{index new create}

  def index
    per_page = 12
    @statuses_arr = (params[:statuses] || []).map(&:to_i).compact
    s_sql = ::PubTripsSearchHelper.get_search_sql(params[:search].to_s, ['tickets.search_text'])
    itms = Ticket.for_trips_scope(current_user.trips).where(s_sql)
    itms = itms.where(slot_status: @statuses_arr) if @statuses_arr.any?
    @items = itms.order(id: :DESC).page(params_page).per(per_page)
  end

  def show

  end

  def update
    item = @current_sold_ticket
    if params[:accept_slot].to_s.size_positive?
      if item.event_ticket_pack.tpack_can_try_give_a_slot?
        if item.update(slot_status: :slot_accepted)
          attrs = { notification_msg_text: "Ticket accepted!", notification_data_json: { url: profile_my_ticket_path(item.id) } }
          user_notify = item.user.user_notifications.create!(attrs)
          user_notify.notification_run_send!
          return success_redirect('Saved', profile_sold_ticket_path(item.id))
        end
      else
        item.errors.add(:slot, "Tickets are over or sale stopped")
      end
    end

    if params[:accept_with_bron].to_s.size_positive?
      if item.update(slot_status: :slot_taked)
        item.event_ticket_pack.unsafe_inc_tickets_slotted_cnt!(1)
        return success_redirect('Saved', profile_sold_ticket_path(item.id))
      end
    end

    if params[:decline_slot].to_s.size_positive?
      old_status = item.slot_status.to_s
      if item.update(slot_status: :slot_declined)
        attrs2 = { notification_msg_text: "Ticket declined", notification_data_json: { url: profile_my_ticket_path(item.id) } }
        user_notify2 = item.user.user_notifications.create!(attrs2)
        user_notify2.notification_run_send!
        if old_status.str_eq?("slot_taked")
          item.event_ticket_pack.unsafe_inc_tickets_slotted_cnt!(-1)
        end
        return success_redirect('Saved', profile_sold_ticket_path(item.id))
      end
    end

    flash2 :alert, "Errors found"
    render action: :show
  end

end
