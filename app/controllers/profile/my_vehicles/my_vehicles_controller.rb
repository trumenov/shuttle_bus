class ::Profile::MyVehicles::MyVehiclesController < Profile::MyVehicles::MyVehiclesBaseController
  skip_before_action :set_current_my_vehicle, only: %w{index new create}

  def index
    main_data[:title] = "MyVehicles list"
    per_page = 12
    ids_sql = ::PubVehiclesSearchHelper.get_search_where_sql(params[:search].to_s, true)
    @items = current_user.vehicles.where(deleted_at: nil).where(ids_sql).page(params_page).per(per_page)
  end

  def new
    main_data[:title] = "new MyVehicle"
    @item = current_user.vehicles.new
    add_breadcrumb "New", new_profile_my_vehicle_path
  end

  def create
    main_data[:title] = "create MyVehicle"
    @item = current_user.vehicles.create(params.require(:vehicle).permit(:name))
    unless @item.errors.any?
      return success_redirect('Created', edit_profile_my_vehicle_path(@item.id))
    end
    render action: :new
  end

  def show
    @item = @current_my_vehicle
    @item.validate!
  end

  def edit
    @item = @current_my_vehicle
    add_breadcrumb "Edit", edit_profile_my_vehicle_path(@item.id)
    main_data[:title] = "Edit MyVehicle \##{ @item.id }"
  end

  def update
    @item = @current_my_vehicle
    # new_vehicle_start_time  = Time.strptime(params[:vehicle_start_time ], "%F %H:%M").localtime
    # new_vehicle_finish_time = Time.strptime(params[:vehicle_finish_time], "%F %H:%M").localtime
    # puts "\n\n\n params[:vehicle_start_time]=[#{ params[:vehicle_start_time] }] new_vehicle_start_time=[#{ new_vehicle_start_time }] \n\n\n"
    tattrs = { deleted_at: nil }
    # tattrs[:visibility_status] = :published if (params[:run_publish_chk] || '0'.to_i.positive?)
    # if @item.can_owner_edit_this_vehicle?
    if @item.update(params.require('vehicle').permit(:name, :vehicle_description_text, :vehicle_seats_cnt).merge(tattrs))
      # if (params[:run_publish_chk] || '0'.to_i.positive?)
      #   if (@item.can_owner_publish_this_vehicle? && self.class.try_publish_the_vehicle!(@item.id))
      #     flash2(:success, 'vehicle published successfully')
      #   else
      #     flash2(:alert, 'vehicle not published. Some errors found.')
      #   end
      # end
      return success_redirect('Saved', profile_my_vehicle_path(@item.id))
    end
    # else
    #   @item.errors.add(:edit, "can not edit this vehicle")
    # end
    flash2 :alert, "Errors found"
    render action: :edit
  end

  def destroy
    @item = @current_my_vehicle
    @item.update!(deleted_at: Time.now())
    return success_redirect('Deleted', profile_my_vehicles_path())
  end

  def choose_vimage_as_logo
    @item = @current_my_vehicle
    params.to_enum.to_h.each do |k, val|
      if k.starts_with?('delete_item_')
        id_for_del = k.gsub(/^delete_item_/, '').to_i || -1
        unless id_for_del.negative?
          @item.valid_vehicle_imgs.detect { |x| x.id.eql?(id_for_del) }.update!(deleted_at: Time.now())
          return success_redirect('Image deleted', profile_my_vehicle_vehicle_imgs_path(@item.id))
        end
      end
    end
    id_for_logo = params.permit(:logo_img_id)[:logo_img_id].to_i || -1
    logo_img = @item.valid_vehicle_imgs.detect { |x| x.id.eql?(id_for_logo) }
    if logo_img
      @item.valid_vehicle_imgs.each_with_index { |x, i| x.update!(prio: x.id.eql?(logo_img.id) ? 0 : i + 1) }
      return success_redirect('Logo choosed', profile_my_vehicle_vehicle_imgs_path(@item.id))
    end
    flash2 :alert, "Errors found"
    render action: :images
  end
end
