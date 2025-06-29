module MegaBar
  module ApplicationHelper
    def record_class(mega_record)
      mega_record.class.to_s.downcase + '-record'
    end

    def record_id(mega_record)
      mega_record.class.to_s.downcase + '-record-' + mega_record.id.to_s if mega_record.id.present?
    end

    def field_class(d_f)
      classes = []
      classes << "format-#{d_f[:field_display].format}"
      classes << "#{d_f[:field].tablename}--#{d_f[:field].field}"
      classes.join(" ")
    end

    def mega_field_id(d_f)
      data_format_id = d_f[:data_format]&.id || 'none'
      "fd-#{d_f[:field_display].id}-f-#{d_f[:field].id}-df-#{data_format_id}"
    end

    def field_wrapper(d_f)
      # byebug
      return 'td' if @mf.name =='ProfileTable' or @mf.name == 'GridHtml'
      return d_f[:field_display].wrapper if d_f[:field_display].wrapper.present?
      # note wrapper should be refactored to be just wrapper.
      @mf.field_wrapper
    end

    def sortable(column, title=nil)
      #422pm.
      return title if !params[:id].blank?
      title ||= column.titleize
      css_class = column == sort_column(@mega_class, @mega_model_properties, params) ? 'current ' + sort_direction(params, @mega_model_properties) : nil
      direction = column == sort_column(@mega_class, @mega_model_properties, params) && sort_direction(params, @mega_model_properties) == 'asc' ? 'desc' : 'asc'
      hsh = {sort: column, direction: direction}
      action = !['show', 'index'].include?(@mega_rout[:action]) ? "/#{@mega_rout[:action]}" : ''

      path = url_for([*@nested_instance_variables, @kontroller_inst.pluralize.to_sym ]) + action + '?' + hsh.to_param
      link_to title, path, class: css_class
      # link_to title, hsh, class: css_class
      # link_to best_in_place sort_column, title, {:sort => column, :direction => direction, controller: @kontroller_path}, class: css_class
    end

    def model_display_classnames
      classnames = []
      classnames << @mf.main_classname if @mf.main_classname.present?
      classnames << @mega_display[:model_display].classname if @mega_display[:model_display].classname.present?
      classnames.join(" ")
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
      param_hash = {}
      @nested_ids.each do |param|
        param_hash = param_hash.merge(param)
      end
      param_hash = param_hash.merge(@p_params)
      param_hash[:action] = action
      param_hash[:id] = id if id
      param_hash[:controller] = params[:controller]
      url_for(param_hash)
    end

    def pre_render
    end
    def filter_contains
      filterr = text_field_tag(param_from_tablename(@mega_model_properties, @displayable_field[:field].tablename) + "[" + @displayable_field[:field].field + "___filter]", '', size: 15 )

    end

    def model_display_help_links
      links = []
      styleClass = @mega_display[:model_display].model.mega_model == 'mega' ? 'megaSetting' : ''
      links << ['/mega-bar/model_displays/' + @mega_display[:model_display].id.to_s  + '?return_to=' + request.env['PATH_INFO'], 'Field Displays for the "' + @mega_display[:model_display].header.to_s +  '" model display']
      # links << ['/mega-bar/model_displays/' + @mega_display[:model_display].id.to_s  + '/edit' , 'Edit Model Display']
      links.map{ |l| link_to l[1], l[0], target: :_blank, class: styleClass}.join(' | ')
    end
    def model_display_collection_help_links
      links = []
      links << ['/mega-bar/model-display-collections/' + @mega_display[:collection_settings].id.to_s + '/edit?return_to=' + request.env['PATH_INFO'], 'Pagination Settings']
      links.map{ |l| link_to l[1], l[0], target: :_blank }.join(' | ')
    end
    def block_help_links
      links = []
      # links << ['/mega-bar/blocks/' + @block.id.to_s + '?return_to=' + request.env['PATH_INFO'], 'Model Displays for the "' + @block.name + '" Block'] if @block.name
      # links << ['/mega-bar/blocks/' + @block.id.to_s + '/edit', 'Edit Block']
      links.map{ |l| link_to l[1], l[0], target: :_blank}.join(' | ')
    end
    def layout_help_links
      links = []
      links << ['/mega-bar/pages/' + @mega_page[:page_id].to_s  + '/layouts/' + @mega_layout.id.to_s  + '?return_to=' + request.env['PATH_INFO'], 'Layout Settings'] unless @mega_page.blank?
      # links << ['/mega-bar/layouts/' + @mega_layout.id.to_s + '/edit', 'Edit Layout']
      links.map{ |l| link_to l[1], l[0], target: :_blank}.join(' | ')
    end
    def page_help_links
      links = []
      styleClass = @mega_page[:page_path].starts_with?('/mega-bar/') ? 'megaSetting' : ''
      links << ['/mega-bar/pages/' + @mega_page[:page_id].to_s + '?return_to=' + request.env['PATH_INFO'], 'Layouts on the "' + @mega_page[:name] + '" Page']
      links << ['/mega-bar/pages/' + @mega_page[:page_id].to_s + '/edit/', 'Edit Page']
      links.map{ |l| link_to l[1], l[0], target: :_blank, class: styleClass}.join(' | ')
    end
    def field_help_links(field)
      links = []
      styleClass = field[:field].model.mega_model == 'mega' ? 'megaSetting' : ''
      links << ['/mega-bar/models/' + field[:field].model_id.to_s + '/fields/' + field[:field].id.to_s + '?return_to=' + request.env['PATH_INFO'], 'Field']
      links << ['/mega-bar/field_displays/' + field[:field_display].id.to_s, 'Field Display']
      links.map{ |l| link_to l[1], l[0], target: :_blank, class: styleClass}.join(' | ')
    end
    def data_display_help_links(field)
      links = []
      links << [MegaBar::Engine.routes.url_for(controller: field[:data_format].controller_name, action: 'edit', id: field[:data_format].id, only_path: true)  + '?return_to=' + request.env['PATH_INFO'], field[:field_display].format.capitalize + ' settings' ]
       # links << [MegaBar::Engine.routes.url_for(controller: '/mega_bar/' + field[:field_display].format.pluralize, action: 'edit', id: field[:data_format].id, :only_path=> true), 'Edit ' + field[:field_display].format.capitalize]
      links.map{ |l| link_to l[1], l[0], target: :_blank}.join(' | ')
    end
    def reorder_up(field, direction)
      return '' unless @authorizations[:block_administrator]
      return '' if @mega_display[:displayable_fields].first[:field_display].position == field[:field_display].position
      links = []
      arrow = direction == 'left' ? '<-' : '^'
      links << ["/mega-bar/field_displays/move/#{field[:field_display].id}?method=move_higher&return_to=" + request.env['PATH_INFO'], arrow]
      links.map{ |l| link_to l[1], l[0], {data: { turbolinks: false }, class: 'admin_links'}}.join(' | ') 
    end
    def reorder_down(field, direction)
      return '' unless @authorizations[:block_administrator]
      return '' if @mega_display[:displayable_fields].last[:field_display].position == field[:field_display].position
      links = []
      arrow = direction == 'right' ? '->' : 'v'
      links << ["/mega-bar/field_displays/move/#{field[:field_display].id}?method=move_lower&return_to=" + request.env['PATH_INFO'] , arrow]
      links.map{ |l| link_to l[1], l[0], {data: { turbolinks: false }, class: 'admin_links'}}.join(' | ')
    end

    def reorder_block_up(block)
      return '' if @layable.layout_section.blocks.first.position == block.position

      links = []
      arrow = '^'
      links << ["/mega-bar/blocks/move/#{block.id}?method=move_higher&return_to=" + request.env['PATH_INFO'] , arrow]
      links.map { |l| link_to l[1], l[0], {data: { turbolinks: false }, class: 'admin_links'}}.join(' | ')
    end

    def reorder_block_down(block)
      return '' if @layable.layout_section.blocks.last.position == block.position

      links = []
      arrow =  'v'
      links << ["/mega-bar/blocks/move/#{block.id}?method=move_lower&return_to=" + request.env['PATH_INFO'] , arrow]
      links.map { |l| link_to l[1], l[0], {data: { turbolinks: false }, class: 'admin_links'}}.join(' | ')
    end

    def data_format_locals(mega_record, displayable_field, value=nil, mega_bar=nil?)
      local = {obj: mega_record, displayable_field: displayable_field, field: displayable_field[:field], field_display: displayable_field[:field_display], options: displayable_field[:options], mega_bar: mega_bar, value: value }
      
      if displayable_field[:data_format].present?
        local[displayable_field[:data_format].class.name.downcase.sub('::', '_').sub('megabar_', '').to_sym] = displayable_field[:data_format]
      else
        # Create empty data format object for the template if none exists
        format_name = displayable_field[:field_display].format.downcase.to_sym
        local[format_name] = {}
      end
      
      local
    end

    def block_action_interpreter(block)
      case block.actions
      when 'show'
        "(used on show)"
      when 'sine'
        "(used on all displays)"
      when "current"
        "(uses current action)"
      else
       'not sure when this block would be used'
      end
    end

    def layout_settings_header(layout = nil)
      if layout.present?
        "<h2>Layout Sections</h2>".html_safe
      end
    end

    def param_separator(record)
      link_path('move', record.id).include?('?') ? '&' : '?'
    end

    def block_admin?
      session[:admin_blocks].include?(@block.id.to_s)
    end

  end

end
