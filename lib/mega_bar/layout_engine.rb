require 'active_record'
require 'sqlite3'
require 'logger'

class LayoutEngine
  def initialize(app, message = "Response Time")
    @app = app
    @message = message
  end
  
  def call(env)
    dup._call(env)
  end
  
  def _call(env)
    if env['PATH_INFO'].end_with?('.css')  || env['PATH_INFO'].end_with?('.js')
      @status, @headers, @response = @app.call(env)
      return  [@status, @headers, self]
    end
        #  id = env['PATH_INFO'][/(\d+)(?!.*\d)/]
    # env['fake_action'] = action



    # env[:QUERY_STRING] ||= {:model_id=>18, :action=>"index", :controller=>"mega_bar/pages"}

    # Rails.application.routes.routes.named_routes.values.map do |route|
    #  puts  "#{route.defaults[:controller]}##{route.defaults[:action]}"
    # end 
    # MegaBar::Engine.routes.routes.named_routes.values.map do |route|
    #  puts  "#{route.defaults[:controller]}##{route.defaults[:action]}"
    # end 
    # byebug
    redirect = false

    request = Rack::Request.new(env)
    rout = {}
    page_route = {}
    page_info = {}
    rout_terms = request.path_info.split('/').reject! { |c| (c.nil? || c.empty?) }
 
    request_path_info = request.path_info.dup
    rout = (Rails.application.routes.recognize_path request_path_info rescue {}) || {} 
    rout = (MegaBar::Engine.routes.recognize_path request_path_info.sub!('/mega-bar/', '') rescue {}) || {}  if rout.empty? 

    rout[:action] = get_action(rout[:action], env['REQUEST_METHOD'])

    # page_path = { id: page[0], path: page[1]} if !rout.empty?
    env['mega_route'] = rout
    MegaBar::Page.all.order(' id desc').pluck(:id, :path).each do | page |
      page_terms = page[1].split('/').map{ | m | m if m[0] != ':'} - ["", nil]
      next if (rout_terms - page_terms).size != rout_terms.size - page_terms.size
      
      #page_rout = (Rails.application.routes.recognize_path page[1] rescue {}) || {} 
      #throwaway_path = page[1].dup
      #page_rout = (MegaBar::Engine.routes.recognize_path throwaway_path.sub!('/mega-bar/', '') rescue {}) || {}  if page_rout.empty? 
      page_info = {page: page, terms: page_terms}
      break 
    end
    orig_query_hash = Rack::Utils.parse_nested_query(env['QUERY_STRING'])
    final_layouts = [] 
    page_layouts = MegaBar::Layout.by_page(page_info[:page][0])
    page_layouts.each do | page_layout |
      blocks = MegaBar::Block.by_layout(page_layout.id).by_actions(rout[:action])
      final_blocks = []
      params_string = ''
      params_hash = {}
      id_hash = {}
      blocks.each do |blck|
        if ! blck.html.nil? && ! blck.html.empty? 
          final_blocks <<  blck.html
        else 
          block_model_displays =   MegaBar::ModelDisplay.by_block(blck.id)
          modle = MegaBar::Model.by_model(block_model_displays.first.model_id).first
          modyule = modle.modyule.empty? ? '' : modle.modyule + '::'  
          kontroller_klass = modyule + modle.classname.classify.pluralize + "Controller"
          kontroller_path = modle.modyule.nil? || modle.modyule.empty? ?   modle.classname.pluralize.underscore :  modyule.split('::').map { | m | m = m.underscore }.join('/') + '/' + modle.classname.pluralize.underscore
          displays = blck.actions == 'current' ? block_model_displays.by_block(blck.id).by_action(rout[:action]) : block_model_displays.by_block(blck.id)
          block_action = displays.empty? ? rout[:action] : displays.first.action
          nested_ids = []
          if !blck.nest_level_1.nil?  && blck.nest_level_1 > 0
            nested_ids << {MegaBar::Model.find(blck.nest_level_1).classname.downcase +  '_id' =>rout[:id] }
            if !blck.nest_level_2.nil?  && blck.nest_level_2 > 0
              puts 'twoooo'
            end
          end

          if !['update', 'create', 'delete'].include?(rout[:action])
            mega_displays_info = []
            displays.each do | display |
              model_display_format = MegaBar::ModelDisplayFormat.find(display.format)
              field_displays = MegaBar::FieldDisplay.by_model_display_id(display.id)
              displayable_fields = []
              field_displays.each do |field_disp|
                field = MegaBar::Field.find(field_disp.field_id)
                if is_displayable?(field_disp.format)
                  #lets figure out how to display it right here.
                  data_format = Object.const_get('MegaBar::' + field_disp.format.classify).by_field_display_id(field_disp.id).last #data_display models have to have this scope!
                  if field_disp.format == 'select'
                    options = MegaBar::Option.where(field_id: field.id).collect {|o| [ o.text, o.value ] }
                  end
                  displayable_fields << {field_display: field_disp, field: field, data_format: data_format, options: options, obj: @mega_instance}
                end
              end
              info = {
                :model_display_format => model_display_format, # Object.const_get('MegaBar::' + MegaBar::RecordsFormat.find(md.format).name).new, 
                :displayable_fields => displayable_fields,
                :model_display => display
              }
              mega_displays_info << info     
            end
          end
          env[:mega_env] = { 
            model_id: modle.id, 
            mega_model_properties: modle,
            klass: modyule + modle.classname.classify, 
            kontroller: kontroller_klass,
            kontroller_inst: modle.classname.underscore,
            kontroller_path: kontroller_path,
            mega_displays: mega_displays_info,
            action: block_action,
            id_field: modle.classname.underscore + '_id',
            nested_ids: nested_ids
          }
          
          id_hash = orig_query_hash.has_key?(modle.classname.underscore + '_id') ? {id: orig_query_hash[modle.classname.underscore + '_id']} : {}
          params_hash = blck.actions == 'current' ? orig_query_hash.merge(rout) : {action: block_action, controller: kontroller_path} 
          params_hash = params_hash.merge(id_hash) 
          env['QUERY_STRING'] = params_hash.to_param # 150221!     
          @status, @headers, @disp_body = kontroller_klass.constantize.action(block_action).call(env)
          redirect = [@status, @headers, @disp_body] if @status == 302
          final_blocks <<  @disp_body.instance_variable_get("@body").instance_variable_get("@stream").instance_variable_get("@buf")[0]
        end
      end
      env['mega_final_blocks'] = final_blocks

      @status, @headers, @layouts = MegaBar::MasterLayoutsController.action(:render_layout_with_blocks).call(env)
      final_layouts <<  @layouts.instance_variable_get("@body").instance_variable_get("@stream").instance_variable_get("@buf")[0]
    end
    env['mega_final_layouts'] = final_layouts
    @status, @headers, @page = MegaBar::MasterPagesController.action(:render_page).call(env)

    final_page = []
    final_page <<  @page.instance_variable_get("@body").instance_variable_get("@stream").instance_variable_get("@buf")[0]
    return redirect ? [redirect[0], redirect[1], ['you are being redirected']] : [@status, @headers, final_page]
  end
  
  def each(&display)
    display.call("<!-- #{@message}: #{@stop - @start} -->\n") if @headers["Content-Type"].include? "text/html"
    @response.each(&display)
  end


  # Helper methods
  def is_displayable?(format)
    return  (format == 'hidden' || format == 'off') ? false : true
  end

  end

  def get_action(action, method)
    case method
    when 'PATCH', 'PUT', 'POST'
      action == 'show'  ? 'update' : 'create'
    when 'DELETE'
      'destroy'
    else
      action
    end
  end
  def action_from_path(path, method, path_segments)
    # called like: 
    #   initial_path_segments = RouteRecognizer.new.initial_path_segments
    #   rout[:action] = action_from_path(env['PATH_INFO'], env['REQUEST_METHOD'], initial_path_segments ) 
    # but not in use
    path_array = path.split('/')
    if method == 'GET'
      if ['edit', 'new'].include?(path_array.last) 
        path_array.last
      elsif path.last.match(/^(\d)+$/)
        'show'
      elsif  path_segments.include?(path_array.last)
        'index'
      else 
        path_array.last
      end
    elsif ['POST', 'PUT', 'PATCH'].include? method
      path.last.match(/^(\d)+$/) ? 'update' : 'create'
    elsif ['DELETE'].include? method
      'delete'
    end


end

class RouteRecognizer
  attr_reader :paths
  
  # To use this inside your app, call:
  # `RouteRecognizer.new.initial_path_segments`
  # This returns an array, e.g.: ['assets','blog','team','faq','users']

  INITIAL_SEGMENT_REGEX = %r{^\/([^\/\(:]+)}

  def initialize
    routes = Rails.application.routes.routes
    paths = routes.collect {|r| r.path.spec.to_s }
    mega_routes = MegaBar::Engine.routes.routes
    mega_paths =  mega_routes.collect {|r| r.path.spec.to_s }
    @paths = paths + mega_paths

  end

  def initial_path_segments
    @initial_path_segments ||= begin
      paths.collect {|path| match_initial_path_segment(path)}.compact.uniq
    end
  end

  def match_initial_path_segment(path)
    if match = INITIAL_SEGMENT_REGEX.match(path)
      match[1]
    end
  end
end