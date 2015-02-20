module MegaBar
  module MegaBarConcern
    extend ActiveSupport::Concern
    def mega_controller
      @mega_controller = env[:mega_env][:kontroller_class].split('::').last
    end
    def mega_displays 
      @mega_displays = mega_displays_info(ModelDisplay.by_model(env[:mega_env][:model_id]).by_action(params[:action]))
    end

    def mega_displays_info(model_displays)
      # yep, this is the main brain that loads all the model, model display, field, field_display stuff. 
      # after this runs you'll see the 'create' and 'update' type methods above run.
      #return redirect_to(new_model_display_path, :notice => "There was no ModelDisplay for that " + params[:action] +" action and " + model_id.to_s + "model_id combo. Would you like to create one?")    unless model_display
      mega_displays_info = []
      model_displays.each do | md |
        field_displays = FieldDisplay.where(model_display_id: md.id)
        displayable_fields = []
        field_displays.each do |field_disp|
          field = Field.find(field_disp.field_id)
          if is_displayable?(field_disp.format)
            #lets figure out how to display it right here.
            data_format = Object.const_get('MegaBar::' + field_disp.format.classify).by_field_display_id(field_disp.id).last #data_display models have to have this scope!
            if field_disp.format == 'select'
              options = !@options[field.tablename.to_sym].nil? && !@options[field.tablename.to_sym][field.field.to_sym].nil? ? @options[field.tablename.to_sym][field.field.to_sym] :  MegaBar::Option.where(field_id: field.id).collect {|o| [ o.text, o.value ] }             
            end
            displayable_fields << {:field_display=>field_disp, :field=>field, :data_format=>data_format, options: options, :obj=>@mega_instance}
          end
        end
        model_display_format = ModelDisplayFormat.find(md.format)
        info = {
          :model_display_format => model_display_format, # Object.const_get('MegaBar::' + MegaBar::RecordsFormat.find(md.format).name).new, 
          :displayable_fields => displayable_fields,
          :form_path => form_path,
          :new_model_display_format => model_display_format,
          :model_display => md
        }
        mega_displays_info << info
      end
      mega_displays_info
    end

    def add_form_path_to_mega_displays(mega_env) 
      mega_env[:mega_displays].each_with_index do | mega_display, index | 
        id = params[:id]
        mega_env[:mega_displays][index][:form_path] = form_path(mega_display[:action], mega_env[:kontroller_path], id)
      end
      mega_env
    end  

    def index
      byebug
      instance_variable_set("@" + env[:mega_env][:kontroller_inst].pluralize,  @mega_class.order(sort_column(@mega_class, @mega_model_properties, params) + " " + sort_direction(params)))
      @mega_instance = instance_variable_get("@" + env[:mega_env][:kontroller_inst].pluralize);
      byebug
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
          MegaBar.call_rake('db:schema:dump') if [1,2].include? env[:mega_env][:model_id] # gets new models into schema
          format.html { redirect_to @mega_instance, notice: 'It was successfully created.' }
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
      instance_variable_set("@" + env[:mega_env][:kontroller_class][9..-1].classify.singularize,  @mega_class.find(params[:id]))
      @mega_instance = instance_variable_get("@" + env[:mega_env][:kontroller_class][9..-1].classify.singularize); 
      @mega_instance.destroy
      respond_to do |format|
        format.html { redirect_to eval(env[:mega_env][:kontroller_inst] + '_url') }
        format.json { head :no_content }
      end
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
