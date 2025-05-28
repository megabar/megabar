module MegaBar
  module DatesHelper
    def format_date_field(obj, field, date_options)
      # Handle different ways date_options might be passed
      date_options = date_options.is_a?(Hash) ? date_options : date_options.try(:attributes) || {}
      
      value = obj.read_attribute(field)
      return '' if value.nil?

      begin
        value = value.is_a?(String) ? DateTime.parse(value) : value
        
        base_format = format_date_value(value, date_options)
        
        if date_options[:format] != 'datepicker' && date_options['format'] != 'datepicker'
          apply_date_transformation(value, base_format, date_options)
        else
          base_format
        end
      rescue => e
        value.to_s
      end
    end

    private

    def format_date_value(value, date_options)
      format = date_options[:format] || date_options['format']
      
      case format
      when 'datepicker'
        content_tag(:input, '', 
          type: 'text',
          class: 'datepicker-input',
          value: value.strftime('%Y-%m-%d'),
          data: {
            include_time: date_options[:include_time] || date_options['include_time'],
            min_date: date_options[:picker_min_date] || date_options['picker_min_date'],
            max_date: date_options[:picker_max_date] || date_options['picker_max_date'],
            default_view: date_options[:picker_default_view] || date_options['picker_default_view'],
          }
        )
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
      else
        base_format
      end
    end
  end
end 