module MegaBar
  module DatesHelper
    def format_date_field(obj, field_name, date_options, form_builder = nil)
      # Handle different ways date_options might be passed
      date_options = date_options.is_a?(Hash) ? date_options : date_options.try(:attributes) || {}
      
      value = obj.respond_to?(:read_attribute) ? obj.read_attribute(field_name) : obj.send(field_name) rescue nil
      
      # Format for datepicker display
      formatted_value = ""
      if value.present?
        begin
          date_value = value.is_a?(String) ? DateTime.parse(value) : value
          include_time = date_options[:include_time] || date_options['include_time']
          formatted_value = include_time ? date_value.strftime('%Y-%m-%dT%H:%M') : date_value.strftime('%Y-%m-%d')
        rescue => e
          formatted_value = value.to_s
        end
      end

      format = date_options[:format] || date_options['format']
      
      if format == 'datepicker' || format == 'date'
        # Generate proper form input
        input_name = form_builder ? "#{form_builder.object_name}[#{field_name}]" : "#{obj.class.name.underscore}[#{field_name}]"
        input_id = form_builder ? "#{form_builder.object_name}_#{field_name}" : "#{obj.class.name.underscore}_#{field_name}"
        
        include_time = date_options[:include_time] || date_options['include_time']
        input_type = include_time ? 'datetime-local' : 'date'
        
        content_tag(:input, '',
          type: input_type,
          name: input_name,
          id: input_id,
          class: 'datepicker-input form-control',
          value: formatted_value,
          data: {
            include_time: include_time,
            min_date: date_options[:picker_min_date] || date_options['picker_min_date'],
            max_date: date_options[:picker_max_date] || date_options['picker_max_date'],
            default_view: date_options[:picker_default_view] || date_options['picker_default_view'] || 'month',
            format: format
          }
        )
      else
        # Handle other display formats (non-editable)
        return '' if value.nil?
        
        begin
          date_value = value.is_a?(String) ? DateTime.parse(value) : value
          base_format = format_date_value(date_value, date_options)
          apply_date_transformation(date_value, base_format, date_options)
        rescue => e
          value.to_s
        end
      end
    end

    # New helper for Rails form builders
    def date_picker_field(form_builder, field_name, date_options = {})
      obj = form_builder.object
      date_record = date_options.is_a?(MegaBar::Date) ? date_options : nil
      options = date_record ? date_record.attributes : date_options
      
      format_date_field(obj, field_name, options, form_builder)
    end

    private

    def format_date_value(value, date_options)
      format = date_options[:format] || date_options['format']
      
      case format
      when 'datepicker', 'date'
        include_time = date_options[:include_time] || date_options['include_time']
        include_time ? value.strftime('%Y-%m-%d %H:%M') : value.strftime('%Y-%m-%d')
      when "dddd, MMMM DD, YYYY"
        value.strftime('%A, %B %d, %Y')
      when "MM/DD/YYYY h:mm a"
        value.strftime('%m/%d/%Y %l:%M %p')
      when "YYYY-MM-DD HH:mm"
        value.strftime('%Y-%m-%d %H:%M')
      when "DD Month YYYY"
        value.strftime('%d %B %Y')
      when "YYMMDD"
        value.strftime('%y%m%d')
      when "DD-Mon-YYYY"
        value.strftime('%d-%b-%Y')
      when "MM/DD/YYYY"
        value.strftime('%m/%d/%Y')
      when "YYYY-MM-DD"
        value.strftime('%Y-%m-%d')
      else
        value.strftime('%Y-%m-%d')
      end
    end

    def apply_date_transformation(value, base_format, date_options)
      transformation = date_options[:transformation] || date_options['transformation']
      return base_format unless transformation.present?

      case transformation
      when 'relative'
        "#{time_ago_in_words(value)} ago"
      when 'duration'
        now = Time.current
        duration = (now - value).abs
        days = (duration / 1.day).floor
        hours = ((duration % 1.day) / 1.hour).floor
        minutes = ((duration % 1.hour) / 1.minute).floor
        "#{days} days, #{hours} hours, #{minutes} minutes"
      when 'fuzzy'
        distance_of_time_in_words(value, Time.current) + " ago"
      else
        base_format
      end
    end
  end
end 