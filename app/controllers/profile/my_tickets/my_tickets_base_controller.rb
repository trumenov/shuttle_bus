class Profile::MyTickets::MyTicketsBaseController < FrontProfileController
  add_breadcrumb "My tickets", :profile_my_tickets_path
  before_action :set_current_my_ticket_item

  def set_current_my_ticket_item
    return @current_my_ticket_item if @current_my_ticket_item
    id = params[:ticket_id] || params[:my_ticket_ticket_id]
    result = current_user.tickets.find(Integer(id))
    unless result
      raise ActionController::RoutingError.new("Ticket #{ id } not found in your profile")
    end
    add_breadcrumb "Ticket \##{ result.id }", profile_my_ticket_path(result.id)
    @current_my_ticket_item = result
    result
  end

end
