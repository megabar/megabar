module MegaBar
  module MegaBarConcern
    extend ActiveSupport::Concern

    def app_init
      #the crazyness starts right here.
      tmp = params[:controller].include?('mega_bar') ? 'MegaBar::' + params[:controller][9..-1].classify : params[:controller].classify
      @the_class = tmp.constantize
    end

    def myinit(model_id)
      # yep, this is the main brain that loads all the model, model display, field, field_display stuff. 
      # after this runs you'll see the 'create' and 'update' type methods above run.
      fields =  Field.by_model(model_id)
      unless fields
        return redirect_to(:root, :notice => "There was no ModelDisplay for that action/format combo. Would you like to create one?")  
      end
      field_ids = []
      fields.each do |f|
        field_ids << f.id
      end 
      field_displays = FieldDisplay.by_fields(field_ids).by_action(params[:action])
      displayable_fields = []
      field_displays.each do |field_disp|
        field = Field.find(field_disp.field_id)
        if is_displayable?(field_disp.format)
          #lets figure out how to display it right here.
          display_format = Object.const_get('MegaBar::' + field_disp.format.classify).by_field_display_id(field_disp.id).last #data_display models have to have this scope!
          displayable_fields << {:field_display=>field_disp, :field=>field, :display_format=>display_format, :obj=>@model}
        end
      end
      model_display = ModelDisplay.by_model(model_id).by_action(params[:action]).last
      unless model_display
        return redirect_to(new_model_display_path, :notice => "There was no ModelDisplay for that " + params[:action] +" action and " + model_id.to_s + "model_id combo. Would you like to create one?")  
      end
      record_format = MegaBar::RecordsFormat.find(model_display.format)
      @mega_bar = {
        :app_format => Object.const_get('MegaBar::' + record_format.name).new, 
        :field_ids => field_ids,
        :fields => fields,
        :field_displays => field_displays,
        :displayable_fields => displayable_fields,
        :form_path => form_path,
        :model_id => model_id,
        :model_display => model_display, 
        :model_properties => Model.find(model_id),
        :record_format => record_format
      }
      @controller = params[:controller].include?('mega_bar') ?  params[:controller][9..-1] :  params[:controller]
    end
    
        # GET /models
        # GET /models.json
    def index
      #seems like you have to have an instance variable for the specific model because if you don't it doesn't pay attention to using your 'layout'
      #so we set one but then for convenience in the layout, we set @models equal to that.

      instance_variable_set("@" + @controller,  @the_class.order(sort_column + " " + sort_direction))
      @models = instance_variable_get("@" + @controller);
      render @index_view_template
    end

    def show
      instance_variable_set("@"  + @controller.singularize,  @the_class.find(params[:id]))
      @models = []
      @models << instance_variable_get("@"  + @controller.singularize);  
      render @show_view_template
    end

    def new
      instance_variable_set("@"  + @controller.singularize,  @the_class.new)
      @model = instance_variable_get("@"  + @controller.singularize);  
      render @new_view_template
    end

    def edit
      instance_variable_set("@"  + @controller.singularize,  @the_class.find(params[:id]))
      @model = instance_variable_get("@"  + @controller.singularize)
      render @edit_view_template
    end

    def create

      @model = @the_class.new(_params)
      respond_to do |format|
        if @model.save
          format.html { redirect_to @model, notice: 'It was successfully created.' }
          format.json { render action: 'show', status: :created, location: @model }
        else
          format.html { render action: 'new' }
          format.json { render json: @model.errors, status: :unprocessable_entity }
        end
      end
    end
        # PATCH/PUT /models/1
    # PATCH/PUT /models/1.json
    def update
      set_the_display
      respond_to do |format|
        if @model.update(_params)
          logger.info "UUUUUUUUUU"
          format.html { redirect_to @model, notice: 'Thing was successfully updated.' }
          format.json { head :no_content }
        else
          logger.info "FffFFFFFFFF"
          format.html { render action: 'edit' }
          format.json { render json: @model.errors, status: :unprocessable_entity }
        end
      end
    end
    def destroy
      instance_variable_set("@" + params[:controller][9..-1].classify.singularize,  @the_class.find(params[:id]))
      @model = instance_variable_get("@" + params[:controller][9..-1].classify.singularize); 
      @model.destroy
      respond_to do |format|
        format.html { redirect_to models_url }
        format.json { head :no_content }
      end
    end

    def set_the_display
      instance_variable_set("@" + params[:controller][9..-1].classify,  @the_class.find(params[:id]))
      @model = instance_variable_get("@" + params[:controller][9..-1].classify);
    end

    def testing
      logger.info 'tested it'
      #abort('tested it i did')
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

    def sort_column
      @the_class.column_names.include?(params[:sort]) ? params[:sort] :  @mega_bar[:model_properties][:default_sort_field]
    end
    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
    end

    def is_displayable?(format)
      if format == 'hidden' || format == 'off'
        false
      else
        logger.info "is_displayable" + format
        true
      end
    end


  end
end
