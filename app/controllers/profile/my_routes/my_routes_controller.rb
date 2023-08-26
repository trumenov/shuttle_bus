class ::Profile::MyRoutes::MyRoutesController < Profile::MyRoutes::MyRoutesBaseController
  skip_before_action :set_current_my_route, only: %w{index new create}

  def index
    main_data[:title] = "MyRoutes list"
    per_page = 12
    ids_sql = ::PubRoutesSearchHelper.get_search_where_sql(params[:search].to_s, true)
    @items = current_user.user_routes.where(deleted_at: nil).where(ids_sql).page(params_page).per(per_page)
  end

  def new
    main_data[:title] = "new MyRoute"
    @item = current_user.user_routes.new
    add_breadcrumb "New", new_profile_my_route_path
  end

  def create
    main_data[:title] = "create MyRoute"
    attrs = { }
    @item = current_user.user_routes.create(params.require(:user_route).permit(:name).merge(attrs))
    unless @item.errors.any?
      return success_redirect('Created', edit_profile_my_route_path(@item.id))
    end
    render action: :new
  end

  def show
    @item = @current_my_route
    @item.validate!
  end

  def edit
    @item = @current_my_route
    add_breadcrumb "Edit", edit_profile_my_route_path(@item.id)
    main_data[:title] = "Edit MyRoute \##{ @item.id }"
  end

  def update
    @item = @current_my_route
    # new_route_start_time  = Time.strptime(params[:route_start_time], "%F %H:%M").localtime
    # new_route_finish_time = Time.strptime(params[:route_finish_time], "%F %H:%M").localtime
    # puts "\n\n\n params[:route_start_time]=[#{ params[:route_start_time] }] new_route_start_time=[#{ new_route_start_time }] \n\n\n"
    tattrs = { deleted_at: nil }
    # tattrs[:visibility_status] = :published if (params[:run_publish_chk] || '0'.to_i.positive?)
    # if @item.can_owner_edit_this_route?
    if @item.update(params.require(:user_route).permit(:name, :route_description_text).merge(tattrs))
      # if (params[:run_publish_chk] || '0'.to_i.positive?)
      #   if (@item.can_owner_publish_this_route? && self.class.try_publish_the_route!(@item.id))
      #     flash2(:success, 'route published successfully')
      #   else
      #     flash2(:alert, 'route not published. Some errors found.')
      #   end
      # end
      return success_redirect('Saved', edit_profile_my_route_path(@item.id))
    end
    # else
    #   @item.errors.add(:edit, "can not edit this route")
    # end
    flash2 :alert, "Errors found"
    render action: :edit
  end

  def destroy
    @item = @current_my_route
    @item.update!(deleted_at: Time.now())
    return success_redirect('Deleted', profile_my_routes_path())
  end

end
