module PubTripsSearchHelper
  # def self.get_trips_collection(params)
  #   ids_sql = get_search_where_sql(params[:search].to_s)
  #   sql_props_h = {}
  #   params_to_filters_h(params).each do |kint, vals|
  #     psql = "SELECT event_id FROM event_props WHERE ((prop_name_sum=#{ kint }) AND (prop_val_sum IN (#{ vals.join(',') })))"
  #     sql_props_h[kint] = "(events.id IN (#{ psql }))"
  #   end
  #   pars_h = params_to_filters_h(params)
  #   # puts "\n\n\n\n\n get_events_collection pars_h=[#{ pars_h.to_json }] \n\n\n\n\n"
  #   filter_items = []
  #   EventsFilterField.visible_for_client.order(prio: :asc, id: :asc).each do |eff_item|
  #     sql_props_wo_this = sql_props_h.except(eff_item.eff_name_sum)
  #     # puts "\n\n\n\n sql_props_wo_this=[#{ sql_props_wo_this }] \n\n\n\n\n"
  #     ids_sql2_wo_this_prop = ids_sql + (sql_props_wo_this.any? ? " AND " + sql_props_wo_this.values.join(" AND ") : "")
  #     sql4 = "SELECT prop_val, prop_val_sum, count(*) AS cnt FROM event_props
  #             WHERE (prop_name_sum=#{ eff_item.eff_name_sum }) AND (event_id IN (SELECT events.id FROM events WHERE (#{ ids_sql2_wo_this_prop })))
  #             GROUP BY prop_val_sum, prop_val ORDER BY prop_val, prop_val_sum LIMIT 100"
  #     prop_vals4 = []
  #     ActiveRecord::Base.connection.execute(sql4).each(:as => :hash) { |x| prop_vals4.push(x) }
  #     if prop_vals4.any?
  #       filter_items.push({ id: eff_item.id, name: eff_item.name, prio: eff_item.prio,
  #                           field_type: :select2_field_type,
  #                           prop_name: eff_item.eff_name_sum, prop_vals: prop_vals4 })
  #     end
  #   end

  #   pars_h.each do |kint, vals|
  #     fitem = filter_items.find { |x| x[:prop_name] == kint }
  #     if fitem
  #       vals.each do |v|
  #         unless fitem[:prop_vals].find { |x| x['prop_val_sum'] == v }
  #           prop_val = ''
  #           sql5 = "SELECT prop_val FROM event_props WHERE ((prop_name_sum=#{ kint }) AND (prop_val_sum=#{ v })) ORDER BY id LIMIT 1"
  #           ActiveRecord::Base.connection.execute(sql5).each(:as => :hash) { |x| prop_val = x['prop_val'] }
  #           if prop_val.size_positive?
  #             fitem[:prop_vals].push({ 'prop_val' => prop_val, 'prop_val_sum' => v, 'cnt' => 0 })
  #             # puts "\n\n\n\n missing2 kint[#{ kint }] v[#{ v }] prop_val=[#{ prop_val }] \n\n\n\n"
  #           end
  #         end
  #       end
  #     else
  #       # puts "\n\n\n\n\n\n not found kint=[#{ kint }] \n\n\n\n\n\n"
  #     end
  #   end

  #   ids_sql2 = ids_sql + (sql_props_h.any? ? " AND " + sql_props_h.values.join(" AND ") : "")
  #   { events: ::Event.where(visibility_status: [1..]).where(ids_sql2).includes(:event_imgs).order(event_rang_pts: :desc, event_start_time: :asc, id: :desc),
  #     ids_sql: ids_sql, filter_items: filter_items }
  # end

  # def self.params_to_filters_h(params)
  #   result = {}
  #   params.to_enum.to_h.each do |k, val|
  #     if k.starts_with?('f')
  #       kint = (k.to_s[1..-1].to_i || 0)
  #       if kint.positive?
  #         vals = val.to_s.scoma_i64
  #         result[kint] = vals if vals.any?
  #       end
  #     end
  #   end
  #   result
  # end

  def self.get_search_where_sql(search_text, show_hidden = false)
    # default_fields = ["ev.search_text", "ev.name", "ev.description"]
    default_fields = ['trips.search_text']
    # search_ands : Array(NamedTuple(word: String, fields: Array(String))) = []
    # where_sql = show_hidden ? '(1)' : '(trip.status > 0)'
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
    get_search_sql(search_text, default_fields, { init_sql: show_hidden ? '(1)' : '(trips.deleted_at IS NULL)' })
  end

  def self.get_search_sql(search_text, fields, params = {})
    # default_fields = ["ev.search_text", "ev.name", "ev.description"]
    # fields = ['trips.search_text']
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
