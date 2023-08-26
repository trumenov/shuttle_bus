# frozen_string_literal: true

class ::PubStations::PubStationsBaseController < ::PagesController
  add_breadcrumb "Stations", :stations_path
  before_action :set_front_side_current_station

  def set_front_side_current_station
    return @front_side_current_station if @front_side_current_station
    id = params[:st_id] || params[:station_st_id]
    result = UserStation.find(Integer(id))
    unless result
      raise ActionController::RoutingError.new("Station #{ id } not found")
    end
    main_data[:title] = "Station \##{ result.id }"
    add_breadcrumb main_data[:title], station_path(result.id)
    @front_side_current_station = result
    result
  end
end
