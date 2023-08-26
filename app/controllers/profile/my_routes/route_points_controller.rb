class ::Profile::MyRoutes::RoutePointsController < Profile::MyRoutes::MyRoutesBaseController
  before_action :set_current_my_route_point
  skip_before_action :set_current_my_route_point, only: %w{index new create}


  def set_current_my_route_point
    return @current_my_route_point if @current_my_route_point
    add_breadcrumb "Edit", edit_profile_my_route_path(@current_my_route.id)
    add_breadcrumb "MyRoutePoints", profile_my_route_route_points_path(@current_my_route.id)
    id = params[:rp_id] || params[:my_route_rp_id]
    result = @current_my_route.user_route_points.detect { |x| x.id.eql?(id.to_i || 0) }
    unless result
      raise ActionController::RoutingError.new("RoutePoint #{ id } not found in your route[#{ @current_my_route.id }]")
    end
    add_breadcrumb "MyRoutePoint \##{ result.id }", profile_my_route_route_point_path(@current_my_route.id, result.id)
    main_data[:title] = "MyRoutePoint \##{ result.id }"
    @current_my_route_point = result
    result
  end

  def index
    add_breadcrumb "Edit", edit_profile_my_route_path(@current_my_route.id)
    add_breadcrumb "MyRoutePoints", profile_my_route_route_points_path(@current_my_route.id)
    # @item = @current_my_route.route_points.new()
    main_data[:title] = "MyRoutePoints"
    @items = @current_my_route.valid_route_points
  end

  def show
    @item = @current_my_route_point
  end

  def edit
    @item = @current_my_route_point
    main_data[:title] = "Edit MyRoutePoint \##{ @item.id }"
    add_breadcrumb "Edit", edit_profile_my_route_route_point_path(@current_my_route.id, @item.id)
  end

  def update
    @item = @current_my_route_point
    add_breadcrumb "Edit", edit_profile_my_route_route_point_path(@current_my_route.id, @item.id)
    main_data[:title] = "Edit MyRoutePoint \##{ @item.id }"
    tattrs = {}
    if @item.update(params.require('user_route_point').permit(:user_station_id, :after_start_planned_seconds, :station_stay_seconds).merge(tattrs))
      return success_redirect('Saved', edit_profile_my_route_route_point_path(@current_my_route.id, @item.id))
    end
    flash2 :alert, "Errors found"
    render action: :edit
  end

  def new
    main_data[:title] = "new MyRoute"
    add_breadcrumb "Edit", edit_profile_my_route_path(@current_my_route.id)
    @item = @current_my_route.user_route_points.new
    add_breadcrumb "New", new_profile_my_route_route_point_path(@current_my_route.id)
    main_data[:title] = "New MyRoutePoint for route \##{ @current_my_route.id }"
  end

  def create
    @item = @current_my_route.user_route_points.new
    add_breadcrumb "Edit", edit_profile_my_route_path(@current_my_route.id)
    add_breadcrumb "RoutePoints", profile_my_route_route_points_path(@current_my_route.id)
    main_data[:title] = "Create MyRoutePoint for route \##{ @current_my_route.id }"
    tattrs = { after_start_planned_seconds: 0, station_stay_seconds: 0 }
    if @item.update(params.require('user_route_point').permit(:user_station_id).merge(tattrs))

      return success_redirect('Saved', edit_profile_my_route_route_point_path(@current_my_route.id, @item.id))
    end
    flash2 :alert, "Errors found"
    render action: :new
  end
end
