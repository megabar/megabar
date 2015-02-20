require 'active_record'
require 'sqlite3'
require 'logger'

class LayoutEngine
  def initialize(app, message = "Response Time")
    @app = app
    #ActiveRecord::Base.logger = Logger.new('debug.log')
    #@configuration = YAML::load(IO.read('config/database.yml'))
    #ActiveRecord::Base.establish_connection(@configuration['development'])
    @message = message
    # modle = MegaBar::Model.all
    # puts modle.inspect

    # env.inspect
    # dogs = render_in_controller(DogsController, 'index')
    # puts dogs.inspect

  end
  
  def call(env)
    dup._call(env)
  end
  
  def _call(env)
    if env['PATH_INFO'].end_with?('.css')  || env['PATH_INFO'].end_with?('.js')
      @status, @headers, @response = @app.call(env)
      return  [@status, @headers, self]
    end
    final= []
    initial_path_segments = RouteRecognizer.new.initial_path_segments
    global_action = action_from_path(env['PATH_INFO'], env['REQUEST_METHOD'], initial_path_segments ) 
    id = env['PATH_INFO'][/(\d+)(?!.*\d)/]
    # env['fake_action'] = action
    page = MegaBar::Page.find(10)
    page_layouts = MegaBar::Layout.by_page(page.id)
    page_layouts.each do | page_layout |
      blocks = MegaBar::Block.by_layout(page_layout.id).by_actions(global_action)
      params_string = ''
      env[:QUERY_STRING] ||= ''
      blocks.each do |blck|
        displays = blck.actions == 'current' ? MegaBar::ModelDisplay.by_block(blck.id).by_action(global_action) : MegaBar::ModelDisplay.by_block(blck.id)
        if !['update', 'create', 'delete'].include?(global_action)
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
                # if field_disp.format == 'select'
                #   options = !@options[field.tablename.to_sym].nil? && !@options[field.tablename.to_sym][field.field.to_sym].nil? ? @options[field.tablename.to_sym][field.field.to_sym] :  MegaBar::Option.where(field_id: field.id).collect {|o| [ o.text, o.value ] }             
                # end
                displayable_fields << {:field_display=>field_disp, :field=>field, :data_format=>data_format, options: @options, :obj=>@mega_instance}
              end
            end
            info = {
              :model_display_format => model_display_format, # Object.const_get('MegaBar::' + MegaBar::RecordsFormat.find(md.format).name).new, 
              :displayable_fields => displayable_fields,
              :new_model_display_format => model_display_format,
              :model_display => display
            }
            mega_displays_info << info     
          end
        end
        modle = MegaBar::Model.by_model(displays.first.model_id).first
        modyule = modle.modyule.empty? ? '' : modle.modyule + '::'  
        kontroller_klass = modyule + modle.classname.classify.pluralize + "Controller"
        env[:mega_env] = { 
          model_id: modle.id, 
          mega_model_properties: modle,
          klass: modyule + modle.classname.classify, 
          kontroller: kontroller_klass,
          kontroller_inst: modle.classname.underscore,
          kontroller_path: modle.modyule.nil? || modle.modyule.empty? ?   modle.classname.pluralize.underscore :  modyule.split('::').map { | m | m = m.underscore }.join('/') + '/' + modle.classname.pluralize.underscore,
          mega_displays: mega_displays_info,
          action: displays.first.action
        }
        byebug
        env[:QUERY_STRING] = env[:QUERY_STRING].sub!(params_string, '')
        params_string = "&action=" + displays.first.action
        params_string += '&id=' +  id.to_s if !id.nil? && !id.empty?
        env["QUERY_STRING"] += params_string
        byebug
        # self.tablename = self.modyule.nil? || self.modyule.empty? ?   self.classname.pluralize.underscore : self.modyule.split('::').map { | m | m = m.underscore }.join('_') + '_' + self.classname.pluralize.underscore
        #     env["QUERY_STRING"] = env["QUERY_STRING"] + '&megab_klass=' + klass + '&megab_kontroller=' + kontroller + '&megab_id=' + modle.id.to_s
        @status, @headers, @dogs = kontroller_klass.constantize.action(env[:mega_env][:action]).call(env)
        # @status, @headers, @dogs = DogsController.action("index").call(env)
        # # byebug
        final <<  @dogs.instance_variable_get("@body").instance_variable_get("@stream").instance_variable_get("@buf")[0]
      end
    end

    # @status, @headers, @reptiles = ReptilesController.action("index").call(env)
    # reptiles = @reptiles.instance_variable_get("@body").instance_variable_get("@stream").instance_variable_get("@buf")[0]
    # both = [dogs, reptiles]
    # @start = Time.now
    # @stop = Time.now
    # # [@status, @headers, both]
    # [@status, @headers, self]
    # MegaBar::Models.all.inspect
    @start = Time.now
    # @status, @headers, @response = @app.call(env)
    @stop = Time.now
    [@status, @headers, final]
  end
  
  def each(&display)
    display.call("<!-- #{@message}: #{@stop - @start} -->\n") if @headers["Content-Type"].include? "text/html"
    @response.each(&display)
  end

  def is_displayable?(format)
    return  (format == 'hidden' || format == 'off') ? false : true
  end

  
  # def internal_redirect_to(options={})
  #   params.merge!(options)
  #   request.env['action_controller.request.path_parameters']['controller'] = params[:controller]
  #   request.env['action_controller.request.path_parameters']['action'] = params[:action]
  #   (c = ActionController.const_get(ActiveSupport::Inflector.classify("#{params[:controller]}_controller")).new).process(request,response)
  #   c.instance_variables.each{|v| self.instance_variable_set(v,c.instance_variable_get(v))} 
  # end

  # def render_in_controller(controller, action)
  #   c = controller.new
  #   c.request = @_request
  #   c.response = @_response
  #   c.params = params
  #   c.process(action)
  #   c.response.body
  # end

  def action_from_path(path, method, path_segments)
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