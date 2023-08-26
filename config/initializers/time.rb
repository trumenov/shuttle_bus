class Time
  def client_to_time_picker_str; localtime.strftime("%F %H:%M").html_safe; end
  def client_stamp_str; localtime.strftime("%F %T").html_safe; end
  def client_stamp_html; "<span class='client_stamp_span'>#{ client_stamp_str }</span>".html_safe; end
  def client_stamp_with_br_html; "<span class='client_stamp_with_br_span'>#{ localtime.strftime("%F<br />%T").html_safe }</span>".html_safe; end
end
