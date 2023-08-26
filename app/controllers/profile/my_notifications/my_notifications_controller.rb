class Profile::MyNotifications::MyNotificationsController < Profile::MyNotifications::MyNotificationsBaseController
  skip_before_action :set_current_my_notification_item, only: %w{index new create}

  def index
    per_page = 12
    ids_sql = ::PubPartiesSearchHelper.get_search_sql(params[:search].to_s, ['user_notifications.notification_msg_text'])
    @items = current_user.user_notifications.where(ids_sql).order(id: :DESC).page(params_page).per(per_page)
  end


end
