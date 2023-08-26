class UserNotificationMailer < ApplicationMailer
  default from: Rails.application.secrets[:gmail_user_name].to_s


  def default_notification_email
    @user = params[:user]
    @notification = params[:notification]
    @url  = UserPushSubscription.gen_dst_url_for_notification(params[:url])
    mail(to: @user.email, subject: 'You have new notification')
  end

end