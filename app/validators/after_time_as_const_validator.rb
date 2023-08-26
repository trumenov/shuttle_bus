class AfterTimeAsConstValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.nil? || value.blank?

    other_time = options.fetch(:with)
    if other_time.nil? || other_time.blank? || (!(other_time.is_a?(Time)))
      raise("Other must be a time. Not[#{ other_time.class }]. other_time=[#{ other_time }]")
    end

    unless value.is_a?(Time)
      raise("value must be a time. Not[#{ value.class }]. value=[#{ value }] after=[#{ other_time }]")
    end

    if value <= other_time
      record.errors.add(attribute, (options[:message] || "must be after #{options[:with].to_s.humanize}"))
    end
  end
end



