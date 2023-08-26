module ApplicationHelper
  def render_flash
    rendered = []
    flash.each do |type, messages|
      if messages.is_a?(Array)
        messages.each do |m|
          unless m.blank?
            rendered.push(render(:partial => 'layouts/flash_one_message', :locals => { :type => type, :message_html => m }))
          end
        end
      else
        rendered.push(render(:partial => 'layouts/flash_one_message', :locals => { :type => type, :message_html => messages }))
      end
    end
    result = "<div class='container render_flash_container'>#{ rendered.join("\n").html_safe }</div>".html_safe
    flash.discard
    result
  end

  def bootstrap_class_for_flash(flash_type)
    case flash_type
    when 'success'
      'alert-success'
    when 'error'
      'alert-danger'
    when 'alert'
      'alert-warning'
    when 'notice'
      'alert-info'
    else
      flash_type.to_s
    end
  end

  def user_avatar_html(user)
    img = image_tag(user.avatar.present? ? url_for(user.avatar) : user.class.no_profile_avatar_sm_url)
    "<div class='user_avatar_block'>#{ img }</div>".html_safe
  end

end
