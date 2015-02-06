module MegaBar
  module MegaBarConcern
    extend ActiveSupport::Concern

    def controller_init(model_id)
      # yep, this is the main brain that loads all the model, model display, field, field_display stuff. 
      # after this runs you'll see the 'create' and 'update' type methods above run.
      #return redirect_to(new_model_display_path, :notice => "There was no ModelDisplay for that " + params[:action] +" action and " + model_id.to_s + "model_id combo. Would you like to create one?")    unless model_display
      @mega_model_properties = Model.find(model_id)
      @mega_infos = []
      ModelDisplay.by_model(model_id).by_action(params[:action]).each do | md |
        field_displays = FieldDisplay.where(model_display_id: md.id)
        displayable_fields = []
        field_displays.each do |field_disp|
          field = Field.find(field_disp.field_id)
          if is_displayable?(field_disp.format)
            #lets figure out how to display it right here.
            display_format = Object.const_get('MegaBar::' + field_disp.format.classify).by_field_display_id(field_disp.id).last #data_display models have to have this scope!
            displayable_fields << {:field_display=>field_disp, :field=>field, :display_format=>display_format, :obj=>@mega_instance}
          end
        end
        info = {
          :app_format => Object.const_get('MegaBar::' + MegaBar::RecordsFormat.find(md.format).name).new, 
          :field_displays => field_displays,
          :displayable_fields => displayable_fields,
          :form_path => form_path,
          :model_id => model_id,
          :model_display => md,
          :record_format => MegaBar::RecordsFormat.find(md.format)
        }
        @mega_infos << info
      end
      @mega_controller = params[:controller].split('/').last # this will not scale for other deeply nested controllers
    end
    
        # GET /models
        # GET /models.json
    def index
      #seems like you have to have an instance variable for the specific model because if you don't it doesn't pay attention to using your 'layout'
      #so we set one but then for convenience in the layout, we set @models equal to that.
      instance_variable_set("@" + @mega_controller,  @mega_class.order(sort_column(@mega_class, @mega_model_properties, params) + " " + sort_direction(params)))
      @mega_instance = instance_variable_get("@" + @mega_controller);
      render @index_view_template
    end

    def show
      instance_variable_set("@"  + @mega_controller.singularize,  @mega_class.find(params[:id]))
      @mega_instance = []
      @mega_instance << instance_variable_get("@"  + @mega_controller.singularize);  
      render @show_view_template
    end

    def new
      instance_variable_set("@"  + @mega_controller.singularize,  @mega_class.new)
      @mega_instance = instance_variable_get("@"  + @mega_controller.singularize);  
      render @new_view_template
    end

    def edit
      instance_variable_set("@"  + @mega_controller.singularize,  @mega_class.find(params[:id]))
      @mega_instance = instance_variable_get("@"  + @mega_controller.singularize)
      render @edit_view_template
    end

    def create
      @mega_instance = @mega_class.new(_params)
      respond_to do |format|
        if @mega_instance.save
          format.html { redirect_to @mega_instance, notice: 'It was successfully created.' }
          format.json { render action: 'show', status: :created, location: @mega_instance }
        else
          format.html { render @new_view_template }
          format.json { render json: @model.errors, status: :unprocessable_entity }
        end
      end
    end
        # PATCH/PUT /models/1
    # PATCH/PUT /models/1.json
    def update
      instance_variable_set("@" + params[:controller][9..-1].classify,  @mega_class.find(params[:id]))
      @mega_instance = instance_variable_get("@" + params[:controller][9..-1].classify);
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
      instance_variable_set("@" + params[:controller][9..-1].classify.singularize,  @mega_class.find(params[:id]))
      @mega_instance = instance_variable_get("@" + params[:controller][9..-1].classify.singularize); 
      @mega_instance.destroy
      respond_to do |format|
        format.html { redirect_to eval(params[:controller].split('/').last + '_url') }
        format.json { head :no_content }
      end
    end
    
    def form_path
      case params[:action]
      when 'index' 
        url_for(controller: params[:controller].to_s,
          action:  params[:action],
          only_path: true)
      when 'new' 
        url_for(controller: params[:controller].to_s,
          action:  'create',
          only_path: true)
      when 'edit' 
        url_for(controller: params[:controller].to_s,
          action:  'update',
          only_path: true)
      else
       form_path = 'ack'
      end
    end 

    def sort_column(mega_class, mega_model_properties, passed_params)
      mega_class.column_names.include?(passed_params[:sort]) ? passed_params[:sort] :  mega_model_properties[:default_sort_field]
    end
    def sort_direction(passed_params)
      byebug
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
