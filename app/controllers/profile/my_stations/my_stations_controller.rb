class ::Profile::MyStations::MyStationsController < Profile::MyStations::MyStationsBaseController
  skip_before_action :set_current_my_station, only: %w{index new create}

  def index
    main_data[:title] = "MyStations list"
    per_page = 12
    ids_sql = ::PubStationsSearchHelper.get_search_where_sql(params[:search].to_s, true)
    @items = current_user.user_stations.where(deleted_at: nil).where(ids_sql).page(params_page).per(per_page)
  end

  def new
    main_data[:title] = "new MyStation"
    @item = current_user.user_stations.new
    add_breadcrumb "New", new_profile_my_station_path
  end

  def create
    main_data[:title] = "create MyStation"
    @item = current_user.user_stations.create(params.require(:user_station).permit(:name))
    unless @item.errors.any?
      return success_redirect('Created', edit_profile_my_station_path(@item.id))
    end
    render action: :new
  end

  def show
    @item = @current_my_station
    @item.validate!
  end

  def edit
    @item = @current_my_station
    add_breadcrumb "Edit", edit_profile_my_station_path(@item.id)
    main_data[:title] = "Edit MyStation \##{ @item.id }"
  end

  def update
    @item = @current_my_station
    # new_station_start_time  = Time.strptime(params[:station_start_time ], "%F %H:%M").localtime
    # new_station_finish_time = Time.strptime(params[:station_finish_time], "%F %H:%M").localtime
    # puts "\n\n\n params[:station_start_time]=[#{ params[:station_start_time] }] new_station_start_time=[#{ new_station_start_time }] \n\n\n"
    more_params = params.require(:user_station).permit(:station_lat_f64, :station_lng_f64)
    station_lat_f64 = BigDecimal(more_params[:station_lat_f64])
    station_lng_f64 = BigDecimal(more_params[:station_lng_f64])
    if station_lat_f64.between?(-90, 90) && station_lng_f64.between?(-180, 180)
      tattrs = { deleted_at: nil, station_lat: station_lat_f64.lat_lng_to_int_p7, station_lng: station_lng_f64.lat_lng_to_int_p7 }
      # tattrs[:visibility_status] = :published if (params[:run_publish_chk] || '0'.to_i.positive?)
      # if @item.can_owner_edit_this_station?
      if @item.update(params.require(:user_station).permit(:name, :station_description_text, :station_lat_f64, :station_lng_f64).merge(tattrs))
        # if (params[:run_publish_chk] || '0'.to_i.positive?)
        #   if (@item.can_owner_publish_this_station? && self.class.try_publish_the_station!(@item.id))
        #     flash2(:success, 'station published successfully')
        #   else
        #     flash2(:alert, 'station not published. Some errors found.')
        #   end
        # end
        return success_redirect('Saved', edit_profile_my_station_path(@item.id))
      end
    else
      @item.errors.add(:coords, "Wrong lat(-90..90) or lng(-180..180)")
    end
    # else
    #   @item.errors.add(:edit, "can not edit this station")
    # end
    flash2 :alert, "Errors found"
    render action: :edit
  end

  def destroy
    @item = @current_my_station
    @item.update!(deleted_at: Time.now())
    return success_redirect('Deleted', profile_my_stations_path())
  end

  def choose_simage_as_logo
    @item = @current_my_station
    params.to_enum.to_h.each do |k, val|
      if k.starts_with?('delete_item_')
        id_for_del = k.gsub(/^delete_item_/, '').to_i || -1
        unless id_for_del.negative?
          @item.valid_station_imgs.detect { |x| x.id.eql?(id_for_del) }.update!(deleted_at: Time.now())
          return success_redirect('Image deleted', profile_my_station_station_imgs_path(@item.id))
        end
      end
    end
    id_for_logo = params.permit(:logo_img_id)[:logo_img_id].to_i || -1
    logo_img = @item.valid_station_imgs.detect { |x| x.id.eql?(id_for_logo) }
    if logo_img
      @item.valid_station_imgs.each_with_index { |x, i| x.update!(prio: x.id.eql?(logo_img.id) ? 0 : i + 1) }
      return success_redirect('Logo choosed', profile_my_station_station_imgs_path(@item.id))
    end
    flash2 :alert, "Errors found"
    render action: :images
  end
end
