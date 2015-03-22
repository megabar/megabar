module MegaBar
  module MegaBarConcern
    extend ActiveSupport::Concern


    def index
      records = @mega_class.where(@conditions).order(sort_column(@mega_class, @mega_model_properties, params) + " " + sort_direction(params))
      instance_variable_set("@" + env[:mega_env][:kontroller_inst].pluralize,  records)
      @mega_instance = instance_variable_get("@" + env[:mega_env][:kontroller_inst].pluralize);
      
      render @index_view_template
    end

    def show
      @mega_instance = []
      instance_variable_set("@"  + env[:mega_env][:kontroller_inst],  @mega_class.find(params[:id]))
      @mega_instance << instance_variable_get("@"  + env[:mega_env][:kontroller_inst]);  
      render @show_view_template
    end

    def new
      instance_variable_set("@"  + env[:mega_env][:kontroller_inst],  @mega_class.new)
      @mega_instance = instance_variable_get("@"  + env[:mega_env][:kontroller_inst]);  
      @form_instance_vars = @nested_instance_variables  + [@mega_instance]
      render @new_view_template
    end

    def edit
      instance_variable_set("@"  + env[:mega_env][:kontroller_inst],  @mega_class.find(params[:id]))
      @mega_instance = instance_variable_get("@"  + env[:mega_env][:kontroller_inst])
      @form_instance_vars = @nested_instance_variables  + [@mega_instance]
      render @edit_view_template
    end



    def create
      @mega_instance = @mega_class.new(_params)
      respond_to do |format|
        if @mega_instance.save
          MegaBar.call_rake('db:schema:dump') if [1,2].include? @model_id # gets new models into schema
          param_hash = {}
          @nested_ids.each do |param|
            param_hash = param_hash.merge(param)
          end
          param_hash[:action] = 'index'
          param_hash[:controller] = params["controller"]
          # param_hash[:id] = id
          param_hash[:only_path] = true
          format.html { redirect_to url_for(param_hash), notice: 'It was successfully created.' }
          format.json { render action: 'show', status: :created, location: @mega_instance }
        else
          format.html { render @new_view_template }
          format.json { render json: @model.errors, status: :unprocessable_entity }
        end
      end
    end
    def update
      instance_variable_set("@" + env[:mega_env][:kontroller_inst], @mega_class.find(params[:id]))
      @mega_instance = instance_variable_get("@" + env[:mega_env][:kontroller_inst]);
      respond_to do |format|
        if @mega_instance.update(_params)
          format.html { redirect_to @mega_instance, notice: 'Thing was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: 'mega_bar.html.erb' }
          format.json { render json: @mega_instance.errors, status: :unprocessable_entity }
        end
      end
    end
    def destroy
      instance_variable_set("@" + env[:mega_env][:kontroller_inst],  @mega_class.find(params[:id]))
      @mega_instance = instance_variable_get("@" + env[:mega_env][:kontroller_inst]); 
      @mega_instance.destroy
      respond_to do |format|
        format.html { redirect_to eval(env[:mega_env][:kontroller_inst].pluralize + '_url') }
        format.json { head :no_content }
      end
    end
    
    def set_vars_for_displays
      @conditions =  {}; self.try(:conditions)
      @options = {}; self.try(:get_options)
      env[:mega_env] = add_form_path_to_mega_displays(env[:mega_env])
      @mega_displays = env[:mega_env][:mega_displays]
    end

    def set_vars_for_all
      
      @mega_class = env[:mega_env][:klass].constantize
      env[:mega_env].keys.each { | env_var | instance_variable_set('@' + env_var.to_s, env[:mega_env][env_var]) }
      unpack_nested_classes(@nested_class_info)
      @index_view_template ||= "mega_bar.html.erb"
      @show_view_template ||= "mega_bar.html.erb"
      @edit_view_template ||= "mega_bar.html.erb"
      @new_view_template ||= "mega_bar.html.erb"
    end

    def unpack_nested_classes(nested_class_infos)
      nested_instance_variables = []
      nested_class_infos.each_with_index do |info, idx|
        puts 'make a instance var!'
        if @nested_ids[idx]
          instance_variable_set("@" + info[1], info[0].constantize.find(@nested_ids[idx].map{|k,v|v}).first) 
          nested_instance_variables << instance_variable_get("@" + info[1]) 
        end
      end
      @nested_instance_variables = nested_instance_variables.reverse
    end
    def conditions
       @conditions.merge!(env[:mega_env][:nested_ids][0]) if env[:mega_env][:nested_ids][0] 
    end
    def add_form_path_to_mega_displays(mega_env) 
      mega_env[:mega_displays].each_with_index do | mega_display, index |
        mega_env[:mega_displays][index][:form_path] = form_path(params[:action], mega_env[:kontroller_path], params[:id])
      end
      mega_env
    end  

    def form_path(action, path, id=nil)
      #used on index and show forms (for filters & reordering)
      param_hash = {}
      @nested_ids.each do |param|
        param_hash = param_hash.merge(param)
      end
      param_hash = param_hash.merge(params.dup)
      param_hash[:id] = id
      param_hash[:only_path] = true
      case action
      when 'new'
        param_hash['action'] = 'create'
      when 'edit' 
        param_hash['action'] = 'update'
      else
         param_hash['action'] = action
      end
      url_for(param_hash)
    end 

    def sort_column(mega_class, model_properties, passed_params)
      mega_class.column_names.include?(passed_params[:sort]) ? passed_params[:sort] :  model_properties[:default_sort_field]
    end
    def sort_direction(passed_params)
      %w[asc desc].include?(passed_params[:direction]) ? passed_params[:direction] : 'asc'
    end

    def is_displayable?(format)
      return  (format == 'hidden' || format == 'off') ? false : true
    end
    def constant_from_controller(str)
      constant_string = ''
      str.split('/').each_with_index do | seg, i |
        constant_string +=  i < str.split('/').size - 1 ? seg.classify + '::' : seg.classify
      end
      constant_string
    end
  end
end
