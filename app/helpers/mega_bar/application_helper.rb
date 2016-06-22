module MegaBar
  module ApplicationHelper
    def sortable(column, title=nil)
      #422pm.
      return title if !params[:id].blank?
      title ||= column.titleize
      css_class = column == sort_column(@mega_class, @mega_model_properties, params) ? 'current ' + sort_direction(params) : nil
      direction = column == sort_column(@mega_class, @mega_model_properties, params) && sort_direction(params) == 'asc' ? 'desc' : 'asc'
      hsh = {sort: column, direction: direction, controller: @kontroller_path}
      hsh.merge!({action: @mega_rout[:action]}) if @mega_rout[:action] != 'show'
      link_to title, hsh, class: css_class
      #link_to best_in_place sort_column, title, {:sort => column, :direction => direction, controller: @kontroller_path}, class: css_class

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
      param_hash = param_hash.merge(params.dup)
      param_hash[:action] = action
      param_hash[:id] = id
      url_for(param_hash)
    end

    def pre_render
    end

    def model_display_help_links
      links = []
      links << ['/mega-bar/pages/' + @mega_page[:page_id].to_s + '/layouts/' + @mega_layout.id.to_s + '/blocks/' + @block.id.to_s + '/model_displays/' + @mega_display[:model_display].id.to_s, 'Field Displays for the "' + @mega_display[:model_display].header.to_s +  '" model display']
      links << ['/mega-bar/pages/' + @mega_page[:page_id].to_s + '/layouts/' + @mega_layout.id.to_s + '/blocks/' + @block.id.to_s + '/model_displays/' + @mega_display[:model_display].id.to_s  + '/edit' , 'Edit Model Display']
      links.map{ |l| link_to l[1], l[0]}.join(' | ')
    end
    def block_help_links
      links = []
      links << ['/mega-bar/pages/' + @mega_page[:page_id].to_s + '/layouts/' + @mega_layout.id.to_s + '/blocks/' + @block.id.to_s, 'Model Displays for the "' + @block.name + '" Block'] if @block.name
      links << ['/mega-bar/pages/' + @mega_page[:page_id].to_s + '/layouts/' + @mega_layout.id.to_s + '/blocks/' + @block.id.to_s + '/edit', 'Edit Block']
      links.map{ |l| link_to l[1], l[0]}.join(' | ')
    end
    def layout_help_links
      links = []
      links << ['/mega-bar/pages/' + @mega_page[:page_id].to_s + '/layouts/' + @mega_layout.id.to_s + '/blocks/' + @block.id.to_s, 'List Model Displays for the ' + @block.name + ' Block']
      links << ['/mega-bar/pages/' + @mega_page[:page_id].to_s + '/layouts/' + @mega_layout.id.to_s + '/blocks/' + @block.id.to_s + '/edit', 'Edit Block']
      links.map{ |l| link_to l[1], l[0]}.join(' | ')
    end
    def layout_help_links
      links = []
      links << ['/mega-bar/pages/' + @mega_page[:page_id].to_s + '/layouts/' + @mega_layout.id.to_s , 'Blocks on the "' + @mega_layout.name + '" Layout']
      links << ['/mega-bar/pages/' + @mega_page[:page_id].to_s + '/layouts/' + @mega_layout.id.to_s + '/edit', 'Edit Layout']
      links.map{ |l| link_to l[1], l[0]}.join(' | ')
    end
    def page_help_links
      links = []
      links << ['/mega-bar/pages/' + @mega_page[:page_id].to_s, 'Layouts on the "' + @mega_page[:name] + '" Page']
      links << ['/mega-bar/pages/' + @mega_page[:page_id].to_s + '/edit/', 'Edit Page']
      links.map{ |l| link_to l[1], l[0]}.join(' | ')
    end
    def field_help_links(field)
      links = []
      links << ['/mega-bar/models/' + field[:field].model_id.to_s + '/fields/' + field[:field].id.to_s, 'Field']
      links << ['/mega-bar/field_displays/' + field[:field_display].id.to_s, 'Field Display']
      links.map{ |l| link_to l[1], l[0]}.join(' | ')
    end
    def data_display_help_links(field)
      links = []
      links << [MegaBar::Engine.routes.url_for(controller: '/mega_bar/' + field[:field_display].format.pluralize, action: 'edit', id: field[:data_format].id, :only_path=> true), 'Edit ' + field[:field_display].format.capitalize]
      # links << [url_for(field[:data_format]) + '/edit', field[:field_display].format.capitalize + ' settings' ]
      links.map{ |l| link_to l[1], l[0]}.join(' | ')
    end
  end

end
