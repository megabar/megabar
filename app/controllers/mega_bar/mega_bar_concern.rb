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
      instance_variable_set("@"  + env[:mega_env][:kontroller_inst],  @mega_class.find(params[:id]))
      @mega_instance = []
      @mega_instance << instance_variable_get("@"  + env[:mega_env][:kontroller_inst]);  
      render @show_view_template
    end

    def new
      instance_variable_set("@"  + env[:mega_env][:kontroller_inst],  @mega_class.new)
      @mega_instance = instance_variable_get("@"  + env[:mega_env][:kontroller_inst]);  
      render @new_view_template
    end

    def edit

      instance_variable_set("@"  + env[:mega_env][:kontroller_inst],  @mega_class.find(params[:id]))
      @mega_instance = instance_variable_get("@"  + env[:mega_env][:kontroller_inst])
      render @edit_view_template
    end



    def create
      puts 'create me'
      @mega_instance = @mega_class.new(_params)
      respond_to do |format|
        if @mega_instance.save
          MegaBar.call_rake('db:schema:dump') if [1,2].include? @model_id # gets new models into schema
          format.html { redirect_to @mega_instance, notice: 'It was successfully created.' }
          format.json { render action: 'show', status: :created, location: @mega_instance }
        else

          format.html { render @new_view_template }
          format.json { render json: @model.errors, status: :unprocessable_entity }
        end
      end
    end
    def update
      byebug
      instance_variable_set("@" + env[:mega_env][:kontroller_inst], @mega_class.find(params[:id]))
      @mega_instance = instance_variable_get("@" + env[:mega_env][:kontroller_inst]);
      byebug
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
      instance_variable_set("@" + env[:mega_env][:kontroller_class][9..-1].classify.singularize,  @mega_class.find(params[:id]))
      @mega_instance = instance_variable_get("@" + env[:mega_env][:kontroller_class][9..-1].classify.singularize); 
      @mega_instance.destroy
      respond_to do |format|
        format.html { redirect_to eval(env[:mega_env][:kontroller_inst] + '_url') }
        format.json { head :no_content }
      end
    end
    
    def set_vars_for_displays
      @conditions =  {}
      @options = {}; self.try(:get_options)
      self.try(:get_options)
      env[:mega_env] = add_form_path_to_mega_displays(env[:mega_env])
      @mega_displays = env[:mega_env][:mega_displays]
      @index_view_template ||= "mega_bar.html.erb"
      @show_view_template ||= "mega_bar.html.erb"
      @edit_view_template ||= "mega_bar.html.erb"
      @new_view_template ||= "mega_bar.html.erb"
    end

    def set_vars_for_all
      @mega_class = env[:mega_env][:klass].constantize
      env[:mega_env].keys.each { | env_var | instance_variable_set('@' + env_var.to_s, env[:mega_env][env_var]) }
    end

    def add_form_path_to_mega_displays(mega_env) 
      mega_env[:mega_displays].each_with_index do | mega_display, index |
        mega_env[:mega_displays][index][:form_path] = form_path(params[:action], mega_env[:kontroller_path], params[:id])
      end
      mega_env
    end  

    def form_path(action, path, id=nil)
      case action
      when 'index' 
        url_for(controller: path.to_s,
          action:  action,
          only_path: true)
      when 'new' 
        url_for(controller: path.to_s,
          action:  'create',
          only_path: true)
      when 'edit'
        url_for(controller: path.to_s,
          action: 'update',
          id: id,
          only_path: true)
      else
       form_path = 'ack'
      end
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
