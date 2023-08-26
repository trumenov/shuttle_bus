class Profile::SoldTickets::SoldTicketsBaseController < FrontProfileController
  add_breadcrumb "Sold tickets", :profile_sold_tickets_path
  before_action :set_current_sold_ticket

  def set_current_sold_ticket
    return @current_sold_ticket if @current_sold_ticket
    id = params[:sold_ticket_id] || params[:sold_ticket_sold_ticket_id]
    result = Ticket.find(id)
    event = current_user.events.detect { |x| x.id.eql?(result.event_ticket_pack.event.id) }
    unless result
      raise ActionController::RoutingError.new("Ticket #{ id } not found in your profile")
    end
    add_breadcrumb "SoldTicket \##{ result.id }", profile_sold_ticket_path(result.id)
    @current_sold_ticket = result
    result
  end

end
