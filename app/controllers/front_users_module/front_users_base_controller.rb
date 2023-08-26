# frozen_string_literal: true

class FrontUsersModule::FrontUsersBaseController < ::PagesController
  add_breadcrumb "Users", :users_path
  before_action :set_front_side_current_user

  def set_front_side_current_user
    return @front_side_current_user if @front_side_current_user
    id = params[:front_user_id] || params[:front_user_front_user_id]
    result = User.find(Integer(id))
    unless result
      raise ActionController::RoutingError.new("User #{ id } not found")
    end
    main_data[:title] = "User \##{ result.id }"
    add_breadcrumb main_data[:title], user_path(result.id)
    @front_side_current_user = result
    result
  end
end
