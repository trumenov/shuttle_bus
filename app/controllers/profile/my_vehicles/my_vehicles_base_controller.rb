class Profile::MyVehicles::MyVehiclesBaseController < FrontProfileController
  add_breadcrumb "My vehicles", :profile_my_vehicles_path
  before_action :set_current_my_vehicle

  def set_current_my_vehicle
    return @current_my_vehicle if @current_my_vehicle
    id = params[:my_vehicle_id] || params[:my_vehicle_my_vehicle_id]
    result = current_user.vehicles.detect { |x| x.id.eql?(id.to_i || 0) }
    unless result
      raise ActionController::RoutingError.new("Vehicle #{ id } not found in your profile")
    end
    add_breadcrumb "Vehicle \##{ result.id }", result.profile_default_url
    main_data[:title] = "MyVehicle \##{ result.id }"
    @current_my_vehicle = result
    result
  end

  # helper_method :my_event_tpack_item_row_html
  # def my_event_tpack_item_row_html(tpack)
  #   render_to_string(partial: "/profile/my_events/my_events/my_event_tpack_row", :locals => { tpack: tpack })
  # end

end
