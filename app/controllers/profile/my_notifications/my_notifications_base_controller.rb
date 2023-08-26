class Profile::MyNotifications::MyNotificationsBaseController < FrontProfileController
  add_breadcrumb "My notifications", :profile_my_notifications_path
  before_action :set_current_my_notification_item

  def set_current_my_notification_item
    return @current_my_notification_item if @current_my_notification_item
    id = params[:my_notification_id] || params[:my_notification_my_notification_id]
    result = current_user.user_notifications.find(Integer(id))
    unless result
      raise ActionController::RoutingError.new("Notification #{ id } not found in your profile")
    end
    add_breadcrumb "Notification \##{ result.id }", profile_my_notification_path(result.id)
    @current_my_notification_item = result
    result
  end

end
