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
    block = MegaBar::Block.find(1)
    modle = MegaBar::Model.by_model(block.model_id).first
    mod = modle.modyule.empty? ? '' : modle.modyule + '::'
    controller = mod + modle.classname.classify.pluralize + "Controller"
    klass = mod + modle.classname.classify

    byebug

    env["QUERY_STRING"] = env["QUERY_STRING"] + '&megab_klass=' + klass + '&megab_kontroller=' + controller + '&megab_id=' + modle.id
    @status, @headers, @dogs = controller.constantize.action("index").call(env)
    byebug
    # @status, @headers, @dogs = DogsController.action("index").call(env)
    # # byebug
    # dogs =  @dogs.instance_variable_get("@body").instance_variable_get("@stream").instance_variable_get("@buf")[0]
    # @status, @headers, @reptiles = ReptilesController.action("index").call(env)
    # reptiles = @reptiles.instance_variable_get("@body").instance_variable_get("@stream").instance_variable_get("@buf")[0]
    # both = [dogs, reptiles]
    # @start = Time.now
    # @stop = Time.now
    # # [@status, @headers, both]
    # [@status, @headers, self]


    # MegaBar::Models.all.inspect
    @start = Time.now
    @status, @headers, @response = @app.call(env)
    @stop = Time.now
    [@status, @headers, self]
  end
  
  def each(&block)
    block.call("<!-- #{@message}: #{@stop - @start} -->\n") if @headers["Content-Type"].include? "text/html"
    @response.each(&block)
  end

  def internal_redirect_to(options={})
    params.merge!(options)
    request.env['action_controller.request.path_parameters']['controller'] = params[:controller]
    request.env['action_controller.request.path_parameters']['action'] = params[:action]
    (c = ActionController.const_get(ActiveSupport::Inflector.classify("#{params[:controller]}_controller")).new).process(request,response)
    c.instance_variables.each{|v| self.instance_variable_set(v,c.instance_variable_get(v))} 
  end

  def render_in_controller(controller, action)
    c = controller.new
    c.request = @_request
    c.response = @_response
    c.params = params
    c.process(action)
    c.response.body
  end

end