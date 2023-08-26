module PubVehiclesSearchHelper
  def self.get_search_where_sql(search_text, show_hidden = false)
    # default_fields = ["ev.search_text", "ev.name", "ev.description"]
    default_fields = ['vehicles.name', 'vehicles.name']
    # search_ands : Array(NamedTuple(word: String, fields: Array(String))) = []
    # where_sql = show_hidden ? '(1)' : '(events.status > 0)'
    # search_ands = []
    # search_text.split(/\s/i).each_with_index do |word, index|
    #   word = word.strip
    #   search_ands << { word: word, fields: default_fields } if word.length.positive?
    # end

    # search_ands.each_with_index do |s_and|
    #   or_words = []
    #   s_and[:fields].each do |fname|
    #     # require_price_rows = true if fname.starts_with?("pr.")
    #     # quoted_word = DB.quote_like(s_and[:word])
    #     quoted_word = ActiveRecord::Base.connection.quote_string(s_and[:word])
    #     or_words.push(" (#{ fname } LIKE \"%#{ quoted_word }%\") ")
    #   end
    #   where_sql += " AND (" + or_words.join(" OR ") + ") " if or_words.size > 0
    # end
    # where_sql
    get_search_sql(search_text, default_fields, { init_sql: show_hidden ? '(1)' : '(events.deleted_at IS NULL)' })
  end

  def self.get_search_sql(search_text, fields, params = {})
    # default_fields = ["ev.search_text", "ev.name", "ev.description"]
    # fields = ['events.search_text']
    # search_ands : Array(NamedTuple(word: String, fields: Array(String))) = []
    where_sql = params[:init_sql] || '(1)'
    search_ands = []
    search_text.split(/\s/i).each_with_index do |word, index|
      word = word.strip
      search_ands.push({ word: word, fields: fields }) if word.length.positive?
    end

    search_ands.each_with_index do |s_and|
      or_words = []
      s_and[:fields].each do |fname|
        # require_price_rows = true if fname.starts_with?("pr.")
        # quoted_word = DB.quote_like(s_and[:word])
        quoted_word = ActiveRecord::Base.connection.quote_string(s_and[:word])
        or_words.push(" (#{ fname } LIKE \"%#{ quoted_word }%\") ")
      end
      where_sql += " AND (" + or_words.join(" OR ") + ") " if or_words.size > 0
    end
    where_sql
  end

end
