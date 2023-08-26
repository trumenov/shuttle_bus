# frozen_string_literal: true

class ::PubTrips::PubTripsBaseController < ::PagesController
  add_breadcrumb "Trips", :trips_path
  before_action :set_front_side_current_trip

  def set_front_side_current_trip
    return @front_side_current_trip if @front_side_current_trip
    id = params[:tr_id] || params[:trip_tr_id]
    result = Trip.find(Integer(id))
    unless result
      raise ActionController::RoutingError.new("Trip #{ id } not found")
    end
    main_data[:title] = "Trip \##{ result.id }"
    add_breadcrumb main_data[:title], trip_path(result.id)
    @front_side_current_trip = result
    result
  end

  helper_method :can_current_user_read_trip_chat?
  def can_current_user_read_trip_chat?
    return false unless current_user && @front_side_current_trip
    # result = false
    # current_user.tickets.where(event_ticket_pack: @front_side_current_trip.trip_ticket_packs).each do |ticket|
    #   result = true if ticket.ticket_allow_user_to_see_chat?
    # end
    # result
    true
  end
end
