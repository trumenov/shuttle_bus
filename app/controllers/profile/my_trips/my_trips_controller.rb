class ::Profile::MyTrips::MyTripsController < Profile::MyTrips::MyTripsBaseController
  skip_before_action :set_current_my_trip, only: %w{index new create}

  def index
    main_data[:title] = "MyTrips list"
    per_page = 12
    ids_sql = ::PubTripsSearchHelper.get_search_where_sql(params[:search].to_s, true)
    @items = current_user.trips.where(deleted_at: nil).where(ids_sql).page(params_page).per(per_page)
  end

  def new
    main_data[:title] = "new MyTrip"
    @item = current_user.trips.new
    add_breadcrumb "New", new_profile_my_trip_path
  end

  def create
    main_data[:title] = "create MyTrip"
    new_trip_start_time  = Time.strptime(params[:trip_start_time], "%F %H:%M").localtime
    attrs = { starts_at_unix: new_trip_start_time.to_i }
    @item = Trip.create(params.require(:trip).permit(:user_route_id, :vehicle_id).merge(attrs))
    unless @item.errors.any?
      return success_redirect('Created', edit_profile_my_trip_path(@item.id))
    end
    render action: :new
  end

  def show
    @item = @current_my_trip
    @item.validate!
  end

  def edit
    @item = @current_my_trip
    add_breadcrumb "Edit", edit_profile_my_trip_path(@item.id)
    main_data[:title] = "Edit MyTrip \##{ @item.id }"
  end

  def update
    @item = @current_my_trip
    new_trip_start_time  = Time.strptime(params[:trip_start_time], "%F %H:%M").localtime
    # new_trip_finish_time = Time.strptime(params[:trip_finish_time], "%F %H:%M").localtime
    # puts "\n\n\n params[:trip_start_time]=[#{ params[:trip_start_time] }] new_trip_start_time=[#{ new_trip_start_time }] \n\n\n"
    tattrs = { deleted_at: nil, starts_at_unix: new_trip_start_time.to_i }
    # tattrs[:visibility_status] = :published if (params[:run_publish_chk] || '0'.to_i.positive?)
    # if @item.can_owner_edit_this_trip?
    if @item.update(params.require(:trip).permit(:name, :trip_description_text, :user_route_id, :vehicle_id).merge(tattrs))
      # if (params[:run_publish_chk] || '0'.to_i.positive?)
      #   if (@item.can_owner_publish_this_trip? && self.class.try_publish_the_trip!(@item.id))
      #     flash2(:success, 'trip published successfully')
      #   else
      #     flash2(:alert, 'trip not published. Some errors found.')
      #   end
      # end
      return success_redirect('Saved', edit_profile_my_trip_path(@item.id))
    end
    # else
    #   @item.errors.add(:edit, "can not edit this trip")
    # end
    flash2 :alert, "Errors found"
    render action: :edit
  end

  def destroy
    @item = @current_my_trip
    @item.update!(deleted_at: Time.now())
    return success_redirect('Deleted', profile_my_trips_path())
  end

  def publish_flag
    @item = @current_my_trip
    add_breadcrumb "Publish", publish_flag_profile_my_trip_path(@item.id)
    main_data[:title] = "Publish trip \##{ @item.id }"
  end

  def publish_flag_update
    @item = @current_my_trip
    add_breadcrumb "Publish", publish_flag_profile_my_trip_path(@item.id)
    main_data[:title] = "Publish trip \##{ @item.id }"
    if @item.update({ published: params[:new_publish_flag].to_i })
      return success_redirect('Published', profile_my_trip_path(@item.id))
    end
    flash2 :alert, "Errors found"
    render action: :publish_flag
  end
end
