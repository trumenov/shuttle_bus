class Profile::MyTickets::MyTicketsController < Profile::MyTickets::MyTicketsBaseController
  skip_before_action :set_current_my_ticket_item, only: %w{index new create}

  def index
    per_page = 12
    ids_sql = ::PubPartiesSearchHelper.get_search_sql(params[:search].to_s, ['tickets.search_text'])
    @items = current_user.tickets.where(ids_sql).order(id: :DESC).page(params_page).per(per_page)
  end

  def load_event_tpack_from_params
    result = EventTicketPack.find(Integer(params[:tpack_id]))
    unless result
      raise ActionController::RoutingError.new("TicketsPack #{ id } not found")
    end
    result
  end

  def new
    add_breadcrumb "New", new_profile_my_ticket_path
    @tpack = load_event_tpack_from_params
  end

  def create
    @tpack = load_event_tpack_from_params
    tattrs = { user: current_user, cost_eur_cts: @tpack.ticket_cost_eur_cts,
               for_owner_eur_cts: @tpack.tpack_calc_one_ticket_payout_for_owner_eur_cts,
               name: "Ticket for #{ @tpack.event.name }",
               event_starts_at: @tpack.event.event_start_time_with_default,
               event_finish_at: @tpack.event.event_finish_time_with_default,
               search_text: [@tpack.event.name, @tpack.event.description].join(' ').to_search_text }
    if @tpack.tpack_can_try_give_a_slot?
      if @tpack.ticket_slot_need_confirmation?
        ticket = @tpack.tickets.create!(tattrs.merge({ slot_status: :slot_asked }))
        return success_redirect("Ticked ordered. You must pay it when owner will accept it.", profile_my_ticket_path(ticket.id))
      else
        # puts "\n\n\n\n NO!!! event_ticket_pack_sale_rule_with_confirmation \n\n\n\n"

        # puts "\n\n\n\n tattrs=[#{ tattrs.to_json }] \n\n\n\n"
        ticket = @tpack.tickets.create!(tattrs)
        if ticket.id.positive?
          if ticket.try_take_slot_in_tpack!
            payment_session = create_payment_session_for_ticket!(ticket)
            # attrs2 = { gateway_name: :stripe, amount_cts: ticket.cost_eur_cts, currency: 'EUR' }
            # new_transaction = ticket.ticket_payments.create!(attrs2)

            # session = Stripe::Checkout::Session.create({
            #   payment_method_types: ['card'],
            #   line_items: [{
            #     price_data: {
            #       currency: 'eur',
            #       product_data: {
            #         name: "Ticket #{ ticket.id } for event #{ @tpack.event_id }",
            #       },
            #       unit_amount: @tpack.ticket_cost_eur_cts,
            #     },
            #     quantity: 1,
            #   }],
            #   mode: 'payment',
            #   client_reference_id: new_transaction.id,
            #   # These placeholder URLs will be replaced in a following step.
            #   success_url: "#{ OmniAuth.config.full_host }/payment_success/#{ new_transaction.id }",
            #   cancel_url:  "#{ OmniAuth.config.full_host }/payment_cancel/#{ new_transaction.id }",
            # })
            # puts "\n\n\n TMP STOP 2332123123123 session=[#{ session.inspect }] \n\n\n\n"
            # new_transaction.update!(gateway_payment_id: session.id.strip, gateway_payment_need_check: 1)
            # raise("ERROR 3123545423543434. Wrong pi.") unless (new_transaction.gateway_payment_id.to_s.size > 5)

            # raise("TMP STOP 1231212312333. intent=[#{ session.inspect }]")
            return redirect_to payment_session.url, :status => 303
          end
          @tpack.errors.add(:slot, "TicketSlot fail")
        end
      end
    else
      @tpack.errors.add(:slot, "Tickets are over")
    end
    flash2 :alert, "Errors found"
    render action: :new
  end

  # def create
  #   @item = current_user.events.create(params.require(:event).permit(:name).merge({ status: :created }))
  #   unless @item.errors.any?
  #     return success_redirect('Created', edit_profile_my_event_path(@item.id))
  #   end
  #   render action: :new
  # end

  def show

  end

  # def edit
  #   @item = @current_my_event
  #   add_breadcrumb "Edit", edit_profile_my_event_path(@item.id)
  # end

  def create_payment_session_for_ticket!(ticket)
    attrs2 = { gateway_name: :stripe, amount_cts: ticket.cost_eur_cts, currency: 'EUR' }
    new_transaction = ticket.ticket_payments.create!(attrs2)

    session = Stripe::Checkout::Session.create({
      payment_method_types: ['card'],
      line_items: [{
        price_data: {
          currency: 'eur',
          product_data: {
            name: "Ticket #{ ticket.id } for event #{ ticket.event_ticket_pack.event_id }",
          },
          unit_amount: ticket.cost_eur_cts,
        },
        quantity: 1,
      }],
      mode: 'payment',
      client_reference_id: new_transaction.id,
      # These placeholder URLs will be replaced in a following step.
      success_url: "#{ OmniAuth.config.full_host }/payment_success/#{ new_transaction.id }",
      cancel_url:  "#{ OmniAuth.config.full_host }/payment_cancel/#{ new_transaction.id }",
    })
    # puts "\n\n\n TMP STOP 2332123123123 session=[#{ session.inspect }] \n\n\n\n"
    new_transaction.update!(gateway_payment_id: session.id.strip, gateway_payment_need_check: 1)
    raise("ERROR 3123545423543434332. Wrong pi.") unless (new_transaction.gateway_payment_id.to_s.size > 5)
    # raise("TMP STOP 1231212312333. intent=[#{ session.inspect }]")
    session
  end

  def update
    item = @current_my_ticket_item
    if params[:try_pay].to_s.size_positive?
      if item.event_ticket_pack.tpack_can_try_give_a_slot? || item.slot_status_slot_taked?
        if item.ticket_need_payment?
          if item.slot_status_slot_taked? || item.try_take_slot_in_tpack!
            payment_session = create_payment_session_for_ticket!(item)
            return redirect_to payment_session.url, :status => 303
          end
          item.errors.add(:slot, "TicketSlot fail")
        end
      else
        item.errors.add(:slot, "Tickets are over")
      end
    end

    if params[:ask_again].to_s.size_positive?
      unless item.ticket_fully_payed?
        unless item.slot_status_id >= 10
          if item.update(slot_status: :slot_asked)
            return success_redirect('Saved', profile_my_ticket_path(item.id))
          end
        end
      end
    end
  #   @item = @current_my_event
  #   new_event_start_time = Time.strptime(params[:event_start_time], "%F %H:%M").localtime
  #   # puts "\n\n\n params[:event_start_time]=[#{ params[:event_start_time] }] new_event_start_time=[#{ new_event_start_time }] \n\n\n"
  #   if @item.update(params.require('event').permit(:name, :description).merge(event_start_time: new_event_start_time))
  #     if (params[:run_publish_chk] || '0'.to_i.positive?)
  #       if (@item.can_owner_publish_this_event? && self.class.try_publish_the_event!(@item.id))
  #         flash2(:success, 'Event published successfully')
  #       else
  #         flash2(:alert, 'Event not published. Some errors found.')
  #       end
  #     end
  #     return success_redirect('Saved', profile_my_event_path(@item.id))
  #   end
  #   flash2 :alert, "Errors found"
    refund_id = params.keys.find { |x| x.to_s.starts_with?('try_refund_') }.to_s.delete_prefix('try_refund_').to_i || 0
    if refund_id.positive?
      if item.ticket_can_be_refunded?
        ticket_payment_for_refund = item.ticket_payments.find { |x| x.id.eql?(refund_id) }
        if ticket_payment_for_refund && ticket_payment_for_refund.try_refund_ticket_payment!
          return success_redirect('Refund success', profile_my_ticket_path(item.id))
        end
      end
    end

    flash2 :alert, "Errors found"
    render action: :show
  end


  # def images
  #   @item = @current_my_event
  #   add_breadcrumb "Images", images_profile_my_event_path(@item.id)
  # end

  # def choose_image_as_logo
  #   @item = @current_my_event
  #   params.to_enum.to_h.each do |k, val|
  #     if k.starts_with?('delete_item_')
  #       indx_for_del = k.gsub(/^delete_item_/, '').to_i || -1
  #       unless indx_for_del.negative?
  #         @item.event_images_sm[indx_for_del].destroy!
  #         @item.event_images[indx_for_del].destroy!
  #         if (@item.logo_img_index.positive? && (@item.logo_img_index >= indx_for_del))
  #           @item.update!(logo_img_index: @item.logo_img_index - 1)
  #         end
  #         return success_redirect('Image deleted', images_profile_my_event_path(@item.id))
  #       end
  #     end
  #   end

  #   if @item.update(params.require('event').permit(:logo_img_index))
  #     return success_redirect('Logo choosed', images_profile_my_event_path(@item.id))
  #   end
  #   flash2 :alert, "Errors found"
  #   render action: :images
  # end

  # def create_image_attachment
  #   @item = @current_my_event
  #   add_breadcrumb "Images", images_profile_my_event_path(@item.id)
  #   if @item.can_owner_attach_image?
  #     if params[:img_file].tempfile.size > 4.megabyte
  #       item.errors.add(:event_images, "is too big. Max 4MB for image.")
  #     else
  #       processed = ImageProcessing::MiniMagick.source(params[:img_file].tempfile).resize_to_limit(140, 140).strip.call
  #       if processed
  #         acceptable_types = ["image/jpeg", "image/png"]
  #         if acceptable_types.include?(MIME::Types.type_for(processed.path).first.content_type)
  #           if @item.event_images.attach(io: params[:img_file].tempfile, filename: params[:img_file].original_filename)
  #             if @item.event_images_sm.attach(io: processed, filename: 'sm_' + params[:img_file].original_filename)
  #               return success_redirect('Image added', images_profile_my_event_path(@item.id))
  #             else
  #               @item.errors.add(:event_images_sm, "Can not attach event_image_sm")
  #             end
  #           else
  #             @item.errors.add(:event_images, "Can not attach event_image")
  #           end
  #         else
  #           errors.add(:event_images, "must be a JPEG or PNG")
  #         end
  #       end
  #     end
  #   else
  #     @item.errors.add(:event_images, "You can not attach image")
  #   end
  #   flash2 :alert, "Errors found"
  #   render action: :images
  # end

  # def change_event_status
  #   @item = @current_my_event
  #   params.to_enum.to_h.each do |k, val|
  #     if k.starts_with?('to_status_')
  #       if k.str_eq?('to_status_returned_for_edit')
  #         wsql1 = "UPDATE events SET status=5 WHERE ((id=#{ @item.id }) AND (status BETWEEN 6 AND 10))"
  #         if (ActiveRecord::Base.connection.update(wsql1) || 0).positive?
  #           return success_redirect('Event returned to edit', edit_profile_my_event_path(@item.id))
  #         end
  #         return alert_redirect('Event NOT returned to edit', edit_profile_my_event_path(@item.id))
  #       elsif k.str_eq?('to_status_decline_this_event')
  #         if @item.can_owner_decline_this_event?
  #           wsql2 = "UPDATE events SET status=55 WHERE ((id=#{ @item.id }) AND (status BETWEEN 10 AND 50))"
  #           if (ActiveRecord::Base.connection.update(wsql2) || 0).positive?
  #             return success_redirect('Event declined successfully', edit_profile_my_event_path(@item.id))
  #           end
  #           return alert_redirect('Event NOT declined. Some errors found.', edit_profile_my_event_path(@item.id))
  #         end
  #         return alert_redirect("Event can NOT be declined. Status: [#{ @item.status }].", edit_profile_my_event_path(@item.id))
  #       elsif k.str_eq?('to_status_publish_this_event')
  #         if @item.can_owner_publish_this_event?
  #           if self.class.try_publish_the_event!(@item.id)
  #             return success_redirect('Event published successfully', profile_my_event_path(@item.id))
  #           end
  #           return alert_redirect('Event NOT published. Some errors found.', profile_my_event_path(@item.id))
  #         end
  #         return alert_redirect("Event can NOT be published. Status: [#{ @item.status }].", profile_my_event_path(@item.id))
  #       elsif k.str_eq?('to_status_copy_this_event')
  #         return alert_redirect("Copy action is not done by chaky yet :(... Sorry please.", edit_profile_my_event_path(@item.id))
  #       else
  #         raise("ERROR 34343223443234. Wrong new event status[#{ k }].")
  #       end
  #     end
  #   end
  #   raise("ERROR 343432244232322. Not found new event status in params.")
  # end

  # def self.try_publish_the_event!(event_id)
  #   wsql2 = "UPDATE events SET status=10 WHERE ((id=#{ event_id }) AND (status BETWEEN 0 AND 9))"
  #   (ActiveRecord::Base.connection.update(wsql2) || 0).positive?
  # end
end
