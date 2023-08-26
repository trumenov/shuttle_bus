class ::ActionController::Base
  attr_accessor :main_data_storage


  helper_method :redirected_in_modal?
  def redirected_in_modal?; (params[:redirected_in_modal].to_s.to_i || 0).positive?; end
  helper_method :from_modal?
  def from_modal?; params[:dialog_wnd_id].to_s.size_positive?; end
  helper_method :main_data
  def main_data
    @main_data_storage ||= { title: 'ShuttleBus' };
    if @main_data_storage[:title].eql?('ShuttleBus')
      lbread = breadcrumbs_on_rails.last
      if lbread
        @main_data_storage[:title] = lbread.name
      end
    end
    @main_data_storage
  end

  def redirect_to(options = {}, response_status = {})
    dst = "#{ Rails.application.secrets.default_url_options[:host] }:#{ Rails.application.secrets.default_url_options[:port] }"
    if options.is_a?(String)
      if from_modal?
        options += ((options.index('?') || -1) > -1 ? '&' : '?') + "dialog_wnd_id=#{ params[:dialog_wnd_id] }&redirected_in_modal=1"
      end
      unless ((options.starts_with?('http') || options.starts_with?('//')))
        options = dst + options
      end
    end
    options = options.gsub('http://hw.dp.ua/', "#{ dst }/").gsub('https://hw.dp.ua/', "#{ dst }/")
    super(options, response_status)
  end

  # def skip_bullet
  #   Bullet.enable = false if Rails.env.development?
  #   yield
  # ensure
  #   Bullet.enable = true if Rails.env.development?
  # end
end

class ::ActionController::API
  def params_page
    page = params[:page].to_s.to_i || 1
    page = 1 unless page.positive?
    page
  end

  # def skip_bullet
  #   Bullet.enable = false if Rails.env.development?
  #   yield
  # ensure
  #   Bullet.enable = true if Rails.env.development?
  # end
end

class ApplicationController < ActionController::Base
  # protect_from_forgery only: :admin_action?
  skip_before_action :verify_authenticity_token

  def flash2(type, text)
    flash[type] ||= []
    flash[type].push(text)
  end

  def alert_redirect  (text, url); flash2(:alert  , text) if text && text.size_positive?; redirect_to url; end
  def success_redirect(text, url); flash2(:success, text) if text && text.size_positive?; redirect_to url; end

  def params_page
    page = params[:page].to_s.to_i || 1
    page = 1 unless page.positive?
    page
  end

  def minfo(item, item_html, list_class = "", ins_prepend = false)
    model_name = item.class.table_name
    model_id = item.id
    list_class = "list_#{ model_name }" unless list_class.size_positive?
    add_model_updated_info(model_name, model_id, "", list_class, item_html, ins_prepend)
  end

  def add_model_updated_info(model_name, model_id, list_html, list_class = "", new_item_html = "", ins_prepend = false)
    cur_str = main_data[:updated_models] || ""
    coma_str = cur_str.size_positive? ? "," : ""
    str = { model_name: model_name, model_id: model_id, list_html: list_html, list_class: list_class, new_item_html: new_item_html, ins_prepend: ins_prepend }.to_json
    main_data[:updated_models] = cur_str + coma_str + str
    true
  end

end
