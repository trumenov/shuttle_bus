class Profile::MyStations::MyStationsBaseController < FrontProfileController
  add_breadcrumb "My stations", :profile_my_stations_path
  before_action :set_current_my_station

  def set_current_my_station
    return @current_my_station if @current_my_station
    id = params[:my_station_id] || params[:my_station_my_station_id]
    result = current_user.user_stations.detect { |x| x.id.eql?(id.to_i || 0) }
    unless result
      raise ActionController::RoutingError.new("Station #{ id } not found in your profile")
    end
    add_breadcrumb "Station \##{ result.id }", result.profile_default_url
    main_data[:title] = "MyStation \##{ result.id }"
    @current_my_station = result
    result
  end
end
