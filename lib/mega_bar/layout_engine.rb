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
    modyule = modle.modyule.empty? ? '' : modle.modyule + '::'
    klass = modyule + modle.classname.classify
    kontroller_klass = modyule + modle.classname.classify.pluralize + "Controller"
    env[:mega_env] = { 
      klass: klass, 
      kontroller: kontroller_klass,
      model_id: modle.id, 
      kontroller_inst: modle.classname.underscore,
      kontroller_path: modle.modyule.nil? || modle.modyule.empty? ?   modle.classname.pluralize.underscore :  modyule.split('::').map { | m | m = m.underscore }.join('/') + '/' + modle.classname.pluralize.underscore,
      mega_model_properties: modle,
      action:'edit'
    }
    env["QUERY_STRING"] = env["QUERY_STRING"] + "&action=edit&id=2"

   # self.tablename = self.modyule.nil? || self.modyule.empty? ?   self.classname.pluralize.underscore : self.modyule.split('::').map { | m | m = m.underscore }.join('_') + '_' + self.classname.pluralize.underscore
   

#     env["QUERY_STRING"] = env["QUERY_STRING"] + '&megab_klass=' + klass + '&megab_kontroller=' + kontroller + '&megab_id=' + modle.id.to_s
    @status, @headers, @dogs = kontroller_klass.constantize.action('edit').call(env)
    # @status, @headers, @dogs = DogsController.action("index").call(env)
    # # byebug
    dogs =  @dogs.instance_variable_get("@body").instance_variable_get("@stream").instance_variable_get("@buf")[0]
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
    [@status, @headers, [dogs]]
  end
  
  def each(&block)
    block.call("<!-- #{@message}: #{@stop - @start} -->\n") if @headers["Content-Type"].include? "text/html"
    @response.each(&block)
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

end