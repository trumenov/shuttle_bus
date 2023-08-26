class Profile::MyRoutes::MyRoutesBaseController < FrontProfileController
  add_breadcrumb "My routes", :profile_my_routes_path
  before_action :set_current_my_route

  def set_current_my_route
    return @current_my_route if @current_my_route
    id = params[:my_route_id] || params[:my_route_my_route_id]
    result = current_user.user_routes.detect { |x| x.id.eql?(id.to_i || 0) }
    unless result
      raise ActionController::RoutingError.new("Route #{ id } not found in your profile")
    end
    add_breadcrumb "Route \##{ result.id }", result.profile_default_url
    main_data[:title] = "MyRoute \##{ result.id }"
    @current_my_route = result
    result
  end
end
