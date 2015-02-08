module MegaBar
  module ApplicationHelper
    def sortable(column, title=nil)
      title ||= column.titleize
      css_class = column == sort_column(@mega_class, @mega_model_properties, params) ? 'current ' + sort_direction(params) : nil
      direction = column == sort_column(@mega_class, @mega_model_properties, params) && sort_direction(params) == 'asc' ? 'desc' : 'asc'
      link_to title, {:sort => column, :direction => direction}, class: css_class
    end

    def param_from_tablename(model_props, tablename)
       
       #if model_props.tablename == tablename

       return 'hi'

      # (byebug) model_props
      # <MegaBar::Model id: 26, classname: "Vow", schema: "sqlite", tablename: "mega_bar_vows", name: "Vows", default_sort_field: "id", created_at: "2015-02-08 03:56:48", updated_at: "2015-02-08 03:56:48", steep: nil, module: "MegaBar">
      # (byebug) tablename
      # "mega_bar_vows"


    end

    def link_path(action = nil, id = nil)
      # application helper
      action ||= params[:action]
      case action
      when 'index' #untested
        url_for(controller: params[:controller].to_s,
        action:  params[:action],
        only_path: true)
      when 'new' 
        url_for(controller: params[:controller].to_s,
        action:  'new',
        only_path: true)
      when 'edit'  #untested
        url_for(controller: params[:controller].to_s,
        action:  'edit',
        :id=>id,#catch errors
        only_path: true)
      when 'show'  #untested
        url_for(controller: params[:controller].to_s,
          :id => id,
          action:  'show',
          only_path: true
        )
      else
        form_path = 'tbd'
      end
    end
    def pre_render
    end
  end

end
