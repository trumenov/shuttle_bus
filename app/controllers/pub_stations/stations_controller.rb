# frozen_string_literal: true

class ::PubStations::StationsController < ::PubStations::PubStationsBaseController
  skip_before_action :set_front_side_current_station, only: %w{index new create}


  def index
    per_page = 24
    # data = ::PubStationsSearchHelper.get_stations_collection(params)
    # events = data[:items]
    search_item = { name: 'Search', prop_name: :search }
    # @filter_items = [search_item] + data[:filter_items]
    ids_sql = ::PubStationsSearchHelper.get_search_where_sql(params[:search].to_s, true)
    @filter_items = [search_item]
    # @items = events.page(params_page).per(per_page)
    @items = UserStation.active.where(ids_sql).page(params_page).per(per_page)
  end

  def show
    @item = @front_side_current_station
  end
end
