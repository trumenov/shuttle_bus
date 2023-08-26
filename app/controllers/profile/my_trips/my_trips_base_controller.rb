class Profile::MyTrips::MyTripsBaseController < FrontProfileController
  add_breadcrumb "My trips", :profile_my_trips_path
  before_action :set_current_my_trip

  def set_current_my_trip
    return @current_my_trip if @current_my_trip
    id = params[:my_trip_id] || params[:my_trip_my_trip_id]
    result = current_user.trips.detect { |x| x.id.eql?(id.to_i || 0) }
    unless result
      raise ActionController::RoutingError.new("Trip #{ id } not found in your profile")
    end
    add_breadcrumb "Trip \##{ result.id }", profile_my_trip_path(result.id)
    main_data[:title] = "MyTrip \##{ result.id }"
    @current_my_trip = result
    result
  end
end
