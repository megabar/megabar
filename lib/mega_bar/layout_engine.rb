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
    action = action_from_path(env['PATH_INFO'], initial_path_segments ) 
    id = env['PATH_INFO'][/(\d+)(?!.*\d)/]

    env['fake_action'] = action
    page = MegaBar::Page.find(1)
    page_layouts = MegaBar::Layout.by_page(page.id)
    page_layouts.each do | page_layout |
      displays = MegaBar::ModelDisplay.by_layout(page_layout.id).by_action(action)
      modle = MegaBar::Model.by_model(displays.first.model_id).first
      modyule = modle.modyule.empty? ? '' : modle.modyule + '::'
      klass = modyule + modle.classname.classify
      kontroller_klass = modyule + modle.classname.classify.pluralize + "Controller"
      mega_displays_info = []
      displays.each do | display |
        field_displays = MegaBar::FieldDisplay.where(model_display_id: 1)
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
        model_display_format = MegaBar::ModelDisplayFormat.find(display.format)
        info = {
          :model_display_format => model_display_format, # Object.const_get('MegaBar::' + MegaBar::RecordsFormat.find(md.format).name).new, 
          :displayable_fields => displayable_fields,
          # :form_path => form_path(env),
          :new_model_display_format => model_display_format,
          :model_display => display
        }
        mega_displays_info << info     
      end
      env[:mega_env] = { 
        klass: klass, 
        kontroller: kontroller_klass,
        model_id: modle.id, 
        kontroller_inst: modle.classname.underscore,
        kontroller_path: modle.modyule.nil? || modle.modyule.empty? ?   modle.classname.pluralize.underscore :  modyule.split('::').map { | m | m = m.underscore }.join('/') + '/' + modle.classname.pluralize.underscore,
        mega_model_properties: modle,
        action: action,
        mega_displays_info: mega_displays_info
      }

      env["QUERY_STRING"] = env["QUERY_STRING"] + "&action=#{action}"
      env["QUERY_STRING"] = env["QUERY_STRING"] + '&id=' +  id.to_s if !id.nil? && !id.empty?

     # self.tablename = self.modyule.nil? || self.modyule.empty? ?   self.classname.pluralize.underscore : self.modyule.split('::').map { | m | m = m.underscore }.join('_') + '_' + self.classname.pluralize.underscore
     

  #     env["QUERY_STRING"] = env["QUERY_STRING"] + '&megab_klass=' + klass + '&megab_kontroller=' + kontroller + '&megab_id=' + modle.id.to_s
      @status, @headers, @dogs = kontroller_klass.constantize.action(action).call(env)
      # @status, @headers, @dogs = DogsController.action("index").call(env)
      # # byebug
      final <<  @dogs.instance_variable_get("@body").instance_variable_get("@stream").instance_variable_get("@buf")[0]
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

  def form_path(env, id=nil)
    byebug
      case env['fake_action']
      when 'index' 
        url_for(controller: env[:mega_env][:kontroller_path].to_s,
          action:  action,
          only_path: true)
      when 'new' 
        url_for(controller: env[:mega_env][:kontroller_path].to_s,
          action:  'create',
          only_path: true)
      when 'edit' 
        url_for(controller: env[:mega_env][:kontroller_path].to_s,
          action: 'update',
          id: params[:id],
          only_path: true)
      else
       form_path = 'ack'
      end
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

  def action_from_path(path, path_segments)
    path_array = path.split('/')
    if ['edit', 'new'].include?(path_array.last) 
      path_array.last
    elsif path.last.match(/^(\d)+$/)
      'show'
    elsif  path_segments.include?(path_array.last)
      'index'
    else 
      path_array.last
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