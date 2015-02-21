module MegaBar 
  class MegaDashesController < MegaBar::ApplicationController
    include MegaBarConcern

    
    def dashboards_init
      initial_path_segments = RouteRecognizer.new.initial_path_segments
      class_segment = segment_for_class(@mega_params["path"], initial_path_segments)
      action = action_from_path(@mega_params["path"], initial_path_segments ) 
      mod = get_module(env['REQUEST_PATH'])
      id = @mega_params["path"][/(\d+)(?!.*\d)/]
      model_id = Model.by_modyule(mod).by_classname(class_segment.classify).pluck(:id).last #no dupes
      controller = controller_for_params(mod, class_segment)
      params = {controller: controller, action: action, model_id: model_id, id: id}
      # {"model_id"=>2, "action"=>"edit", "controller"=>"mega_bar/fields", "id"=>"1"}
      # controller_class = controller.constantize
      require 'Rack'
      
      params.each_with_index do |v, k |
        byebug
        Rack::Request.update_param(k, v)
        
      end
      
      @dogs = FieldsController.action("index").call(env)
      
      render inline: @dogs[2].instance_variable_get("@body").instance_variable_get("@stream").instance_variable_get("@buf")[0]
 

    end

    def other_init
      initial_path_segments = RouteRecognizer.new.initial_path_segments
      class_segment = segment_for_class(@mega_params["path"], initial_path_segments)
      action = action_from_path(@mega_params["path"], initial_path_segments ) 
      mod = get_module(env['REQUEST_PATH'])
      id = @mega_params["path"][/(\d+)(?!.*\d)/]
      model_id = Model.by_modyule(mod).by_classname(class_segment.classify).pluck(:id).last #no dupes
      controller = controller_for_params(mod, class_segment)
      params = {controller: controller, action: action, model_id: model_id, id: id}
      # {"model_id"=>2, "action"=>"edit", "controller"=>"mega_bar/fields", "id"=>"1"}
      # controller_class = controller.constantize
      controller_class = controller_class(mod, class_segment).constantize
      cc = controller_class.new
      cc.instance_variable_set("@params", params)
      cc.instance_variable_set("@mega_class", mega_class(mod, class_segment))
      cc.instance_variable_set("@mega_controller", controller.split('/').last)  if ["index", "show", "edit", "new"].include?params[:action]
      cc.instance_variable_set("@options", {})
      cc.try(:get_options)
      cc.instance_variable_set("@mega_model_properties", mega_model_properties(params)) if ["index", "show", "edit", "new"].include?params[:action]
      cc.instance_variable_set("@mega_displays", mega_displays(params)) if ["index", "show", "edit", "new"].include?params[:action]
      cc.try(:mega_template)
      byebug
      cc.try(:index)
    end

    private

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
    def get_module(env_path)
      env_path_array = env_path.split('/')
      ['mega_bar', 'mega-bar'].include?(env_path_array.second) ? 'MegaBar' : ''
    end
    def mega_class(mod, class_segment)
      mod = mod.empty? ? '' : mod + '::'
      (mod + class_segment.classify).constantize
    end
    def segment_for_class(path, path_segments)
      path_array = path.split('/')
      if path_array.last == 'edit'
        path_array[path_array.size - 3]
      elsif path_array.last == 'new' || path.last.match(/^(\d)+$/)
        path_array[path_array.size -2]
      elsif  path_segments.include?(path_array.last)
        path_array.last
      else
        path_array[path_array.size - 2]
      end
    end
    def controller_for_params(mod, class_segment)
       mod = mod.empty? ? '' : mod.underscore + '/'
       mod + class_segment
     end
     def get_id(path, path_segments)
       path_array = path.split('/').reverse
       path_array.each do |segment|
         next if ['edit', 'new'].include? segment

         return if path_segments.include? segment

       end
       
     end

     def controller_class(mod, class_segment)
       mod = mod.empty? ? '' : mod + '::'
       mod +  class_segment.classify.pluralize + "Controller"
     end

  end


end 
