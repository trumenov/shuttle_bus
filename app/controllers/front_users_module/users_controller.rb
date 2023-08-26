# frozen_string_literal: true

class ::FrontUsersModule::UsersController < ::FrontUsersModule::FrontUsersBaseController
  skip_before_action :set_front_side_current_user, only: %w{index new create}

  def index
    add_breadcrumb "Users", :users_path
    per_page = 24
    # events_data = ::PubPartiesSearchHelper.get_events_collection(params)
    # events = events_data[:events]
    # search_item = { name: 'Search', prop_name: :search }
    # @filter_items = [search_item] + events_data[:filter_items]
    ids_sql = ::PubUsersSearchHelper.get_search_where_sql(params[:search].to_s, true)
    @items = User.where(deleted_at: nil).where(ids_sql).page(params_page).per(per_page)
  end

  def show
    @item = @front_side_current_user
  end
end
