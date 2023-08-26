class ActiveRecord::Base
  strip_attributes

  def item_row_attributes_html(item_num = -1, params = {})
    list_item_class = "list_item_block"
    b_color = ''
    if updated_at
      edited_coef = ((Time.now().localtime.to_i - updated_at.to_i) / 5).to_i
      hex_col = edited_coef > 15 ? "f" : edited_coef.to_s(16)
      b_color = edited_coef > 15 ? "" : "style='border: 1px solid \##{ hex_col }f#{ hex_col };'"
    end
    " class='list_item_block' list_item_model='#{ self.class.table_name }' list_item_id='#{ id }' item_num='#{ item_num }' #{ b_color } ".html_safe
  end

  def created_at_unixtime; created_at.nil? ? nil : created_at.to_time.to_i; end
  def updated_at_unixtime; updated_at.to_time.to_i; end
end
