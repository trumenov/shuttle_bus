class ::PubTrips::PointsController < ::PubTrips::PubTripsBaseController
  before_action :set_current_trip_point
  skip_before_action :set_current_trip_point, only: %w{index new create}


  def set_current_trip_point
    return @current_trip_point if @current_trip_point
    add_breadcrumb "TripPoints", trip_points_path(@front_side_current_trip.id)
    id = params[:trp_id] || params[:trip_trp_id] || 0
    result = @front_side_current_trip.user_route.user_route_points.detect { |x| x.id.eql?(id.to_i) }
    unless result
      raise ActionController::RoutingError.new("TripPoint[#{ id }] not found in trip[#{ @front_side_current_trip.id }]")
    end
    add_breadcrumb "TripPoint \##{ result.id }", trip_point_path(@front_side_current_trip.id, result.id)
    main_data[:title] = "TripPoint \##{ result.id }"
    @current_trip_point = result
    result
  end

  def index
    add_breadcrumb "TripPoints", profile_my_trip_trip_points_path(@front_side_current_trip.id)
    # @item = @front_side_current_trip.trip_points.new()
    main_data[:title] = "TripPoints"
    @items = @front_side_current_trip.user_route.valid_route_points
  end

  def show
    @item = @current_trip_point
  end


end
