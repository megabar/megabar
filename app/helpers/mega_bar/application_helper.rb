module MegaBar
  module ApplicationHelper
    def sortable(column, title=nil)
      title ||= column.titleize
      css_class = column == sort_column(@mega_class, @mega_model_properties, params) ? 'current ' + sort_direction(params) : nil
      direction = column == sort_column(@mega_class, @mega_model_properties, params) && sort_direction(params) == 'asc' ? 'desc' : 'asc'
      link_to title, {:sort => column, :direction => direction, controller: @kontroller_path}, class: css_class
    end

    def param_from_tablename(model_props, tablename)
      # used in data_display stuff. but might could be replaced with env[:mega_env] stuff
      
      # if tablename starts with the module from the model_props, then chop it.
      # else just use it and hope for the best. 
      # Joining to foreign modules not supported and what will happen is forms won't save if the table 
      # additional possible logic:
      # else if you can find that the table couldn't be namespaced, then use that
      # elseif theres a module out there for it use it #todo: 
      # else  use as is.... 

      prefix = model_props.modyule.nil? || model_props.modyule.empty? ? '8675309' : model_props.modyule.split('::').map { | m | m.underscore }.join('_') + '_'
      tablename.start_with?(prefix) ? tablename[prefix.size..-1].singularize : tablename.singularize

    end

    def link_path(action = nil, id = nil)
      # application helper
      ph = {}
      @nested_ids.each do |param|
        ph = ph.merge(param)
      end
      ph = ph.merge(params.dup)
      ph[:action] = action
      ph[:id] = id
      return url_for(ph)
    end
    def pre_render
    end
  end

end
