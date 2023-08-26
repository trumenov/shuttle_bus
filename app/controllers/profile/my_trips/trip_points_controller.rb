class ::Profile::MyTrips::TripPointsController < Profile::MyTrips::MyTripsBaseController
  before_action :set_current_my_trip_point
  skip_before_action :set_current_my_trip_point, only: %w{index new create}


  def set_current_my_trip_point
    return @current_my_trip_point if @current_my_trip_point
    add_breadcrumb "Edit", edit_profile_my_trip_path(@current_my_trip.id)
    add_breadcrumb "MyTripPoints", profile_my_trip_trip_points_path(@current_my_trip.id)
    id = params[:trp_id] || params[:my_trip_trp_id]
    result = @current_my_trip.user_route.user_route_points.detect { |x| x.id.eql?(id.to_i || 0) }
    unless result
      raise ActionController::RoutingError.new("TripPoint[#{ id }] not found in your trip[#{ @current_my_trip.id }]")
    end
    add_breadcrumb "MyTripPoint \##{ result.id }", profile_my_trip_trip_point_path(@current_my_trip.id, result.id)
    main_data[:title] = "MyTripPoint \##{ result.id }"
    @current_my_trip_point = result
    result
  end

  def index
    add_breadcrumb "Edit", edit_profile_my_trip_path(@current_my_trip.id)
    add_breadcrumb "MyTripPoints", profile_my_trip_trip_points_path(@current_my_trip.id)
    # @item = @current_my_trip.trip_points.new()
    main_data[:title] = "MyTripPoints"
    @items = @current_my_trip.user_route.valid_route_points
  end

  def show
    @item = @current_my_trip_point
  end


end
