class FrontProfileController < PagesController
  before_action :authenticate_user!
  add_breadcrumb "Profile", :user_root_path
  @minimum_password_length = 6

  def user_profile_show
    # Devise::Mailer.confirmation_instructions(current_user, current_user.).deliver
    # current_user.send_confirmation_instructions
    # render "here!"
  end

  def authenticate_user!
    result = super
    if current_user && current_user.user_soft_deleted?
      flash2 :alert, "Account will be deleted at #{ current_user.user_full_deletion_time.client_stamp_html }. #{ ActionController::Base.helpers.link_to('restore', edit_user_registration_path).html_safe }".html_safe
    end
    result
  end

  def user_profile_public_info_edit
    add_breadcrumb "Public Info", :profile_public_info_path

  end

  def user_profile_public_info_save
    item = current_user

    new_avatar = params[:new_avatar]
    if new_avatar && (!(new_avatar.is_a?(String) && new_avatar.length.zero?))
      processed = ImageProcessing::MiniMagick.source(new_avatar.tempfile).resize_to_limit(60, 60).strip.call
      if processed
        if item.avatar.attach(io: new_avatar.tempfile, filename: new_avatar.original_filename)
          flash2 :success, 'Avatar changed'
          # if item.avatar_sm.attach(io: processed, filename: 'sm_' + new_avatar.original_filename)
          #   flash2 :success, 'Avatar changed'
          # else
          #   item.errors.add(:avatar_sm, "Can not attach avatar_sm")
          # end
        else
          item.errors.add(:avatar, "Can not attach avatar")
        end
      end
    end

    if item.errors.empty? && item.save
      flash2 :success, 'Saved' if item.previous_changes.any?
      return redirect_to(profile_public_info_path)
    end
    flash2 :alert, "Errors found"
    render :action => 'user_profile_public_info_edit'
  end

  def user_profile_password_change_edit
    add_breadcrumb "Change password", :profile_password_change_path
  end

  def user_profile_password_change_save
    add_breadcrumb "Change password", :profile_password_change_path
    validator = ::UserChangePassValidator.new(current_user, user_profile_password_change_params)
    if validator.valid?
      attrs = { password: user_profile_password_change_params[:password],
                current_password_unknown: 0, password_changed_at: Time.now().localtime }
      if current_user.update!(attrs)
        return success_redirect('Password changed', profile_password_change_path)
      end
    end
    current_user.errors.merge!(validator.errors)
    flash2 :alert, "Errors found"
    render :action => :user_profile_password_change_edit
  end

  def user_profile_password_change_params
    params.require(:user).permit(:password, :password_confirmation, :current_password)
  end

  def user_profile_change_email_edit
    add_breadcrumb "Change email", :profile_change_email_path
  end

  def user_profile_change_email_save
    add_breadcrumb "Change email", :profile_change_email_path
    if current_user.update!(user_profile_change_email_params)
      # current_user.generate_confirmation_token!
      current_user.confirmation_token = nil
      current_user.send_reconfirmation_instructions
      return success_redirect('Sended confirmation instructions to new email', user_root_path)
    end
    flash2 :alert, "Errors found"
    render :action => :user_profile_change_email_edit
  end

  def user_profile_change_email_params
    params.require(:user).permit(:unconfirmed_email)
  end

  def subscribe_notifications
    subs = params.require(:subscription).permit(:endpoint, :expirationTime, keys: [:auth, :p256dh])
    auth = subs[:keys][:auth].strip
    if auth.size_positive?
      current_subscription = current_user.user_push_subscriptions.find { |x| x.webpush_key_auth.eql?(auth) }
      if current_subscription
        current_subscription.send_message("Notifications already enabled")
        return render :json => { result: 0, err: "Already subscribed [#{ auth }]" }
      else
        attrs = { push_subscription_data_json: JSON.parse(subs.to_h.to_json).to_json }
        new_subscr = current_user.user_push_subscriptions.new(attrs)
        if new_subscr.send_message("Notifications enabled!") && new_subscr.save!
          return render :json => { result: 1 }
        end
      end
    end
    render :json => { result: 0, err: "No keys[auth]" }
  end

  # def user_profile_my_events_list
  #   add_breadcrumb "My events", :profile_my_events_path
  #   per_page = 12
  #   ids_sql = ::PubPartiesSearchHelper.get_search_where_sql(params[:search].to_s, true)
  #   @items = current_user.events.where(ids_sql).page(params_page).per(per_page)
  # end

  # def front_current_my_event!
  #   add_breadcrumb "My events", :profile_my_events_path
  #   id = params[:my_event_id].to_i || 0
  #   result = id.positive? ? current_user.events.detect { |x| x.id.eql?(id) } : current_user.events.new
  #   unless result
  #     raise ActionController::RoutingError.new("Event #{ id } not found in your profile")
  #   end
  #   add_breadcrumb "Event #{ result.id }", result.profile_default_url
  #   result
  # end

  # def user_profile_my_events_show
  #   @item = front_current_my_event!
  # end

  # def user_profile_my_events_edit
  #   @item = front_current_my_event!
  # end

  # def user_profile_my_events_save
  #   @item = front_current_my_event!
  #   if @item.update!(user_profile_my_event_params)
  #     return success_redirect('Saved', @item.profile_default_url)
  #   end
  #   flash2 :alert, "Errors found"
  #   render :action => :user_profile_my_events_edit
  # end

  # def user_profile_my_event_params
  #   params.require(:event).permit(:name)
  # end
end
