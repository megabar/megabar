module MegaBar
  module MegaBarConcern
    extend ActiveSupport::Concern

    def index
      records = @mega_class.where(@conditions).where(@conditions_array).order(column_sorting)
      instance_variable_set("@" + @kontroller_inst.pluralize,  records)
      @mega_instance ||= instance_variable_get("@" + @kontroller_inst.pluralize);
      @mega_instance = @mega_instance.page(@page_number).per(num_per_page) if might_paginate?
      @mega_instance = process_filters(@mega_instance)
      render @index_view_template
    end

    def show
      @mega_instance ||= []
      instance_variable_set("@"  + @kontroller_inst,  @mega_class.find(params[:id]))
      @mega_instance << instance_variable_get("@"  + @kontroller_inst);
      render @show_view_template
    end

    def new
      session[:return_to] = request.referer
      instance_variable_set("@"  + @kontroller_inst,  @mega_class.new)
      @mega_instance = instance_variable_get("@"  + @kontroller_inst);
      @form_instance_vars = @nested_instance_variables  + [@mega_instance]
      render @new_view_template
    end

    def edit
      session[:return_to] = request.referer
      instance_variable_set("@"  + @kontroller_inst,  @mega_class.find(params[:id]))
      @mega_instance = instance_variable_get("@"  + @kontroller_inst)
      @form_instance_vars = @nested_instance_variables  + [@mega_instance]
      render @edit_view_template
    end

    def test_create # $20 bounty for understanding why this is here and figuring out how to get rid of it! (hint: tests break without it)
       create
    end
    def create
      @mega_instance = @mega_class.new(_params)
      respond_to do |format|
        if @mega_instance.save
          MegaBar.call_rake('db:schema:dump') if [1,2].include? @model_id and Rails.env != 'test'# gets new models into schema
          param_hash = {}
          @nested_ids.each do |param|
            param_hash = param_hash.merge(param)
          end
          param_hash[:controller] = params["controller"]
          if @mega_instance.id
            # todo: add configuration to model_display for where to go after insert.
            param_hash[:id] = @mega_instance.id if @mega_instance.id #danger.. added during testing.
            param_hash[:action] = 'show'
          else
            param_hash[:action] = 'index'
          end
          param_hash[:only_path] = true
          format.html { redirect_to url_for(param_hash), notice: 'It was successfully created.' }
          format.json { render action: 'show', status: :created, location: @mega_instance }
        else
          format.html {
            redo_setup('new')
            render @new_view_template
           }
          format.json { render json: @model.errors, status: :unprocessable_entity }
        end
      end
    end

    def update
      instance_variable_set("@" + @kontroller_inst, @mega_class.find(params[:id]))
      @mega_instance = instance_variable_get("@" + @kontroller_inst)
      respond_to do |format|
        if @mega_instance.update(_params)
          session[:return_to] ||= request.referer
          format.html { redirect_to session.delete(:return_to), notice: 'Thing was successfully updated.' }
          format.json { respond_with_bip(@mega_instance) }
        else
          format.html {
            redo_setup('edit')
            render action: 'mega_bar.html.erb'
          }
          format.json { render json: @mega_instance.errors, status: :unprocessable_entity }
        end
      end
    end
    def destroy
      instance_variable_set("@" + @kontroller_inst,  @mega_class.find(params[:id]))
      @mega_instance = instance_variable_get("@" + @kontroller_inst);
      session[:return_to] ||= request.referer

      @mega_instance.destroy
      respond_to do |format|
        format.html {  redirect_to session.delete(:return_to), notice: 'You nuked it properly.' }
        format.json { head :no_content }
      end
    end

    def set_vars_for_displays
      @conditions =  {}; self.try(:conditions) #allows various 'where' statements in queries.
      @conditions_array =  []; self.try(:conditions_array)
      @options = {}; self.try(:get_options) # allows for queries to populate menus
      env[:mega_env] = add_form_path_to_mega_displays(env[:mega_env])
      @default_options = {}
      @mega_displays = env[:mega_env][:mega_displays]
    end

    def set_vars_for_all
      @mega_page = env[:mega_page]
      @mega_rout = env[:mega_rout]
      @mega_layout = env[:mega_layout]
      @mega_class = env[:mega_env][:klass]
      @mega_layout_section = env[:mega_layout_section]
      env[:mega_env].keys.each { | env_var | instance_variable_set('@' + env_var.to_s, env[:mega_env][env_var]) }
      unpack_nested_classes(@nested_class_info)
      @index_view_template ||= "mega_bar.html.erb"
      @show_view_template ||= "mega_bar.html.erb"
      @edit_view_template ||= "mega_bar.html.erb"
      @new_view_template ||= "mega_bar.html.erb"
      session[:mega_filters] ||= {}
    end

    def unpack_nested_classes(nested_class_infos)
      # nested as in nested resource routes.
      nested_instance_variables = []
      nested_class_infos.each_with_index do |info, idx|
        # puts 'make a instance var!'
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
    def sort_direction(passed_params, model_properties)
      %w[asc desc].include?(passed_params[:direction]) ? passed_params[:direction] :  model_properties[:default_sort_order]
    end

    def is_displayable?(format)
      return  (format == 'hidden' || format == 'off') ? false : true
    end

    def might_paginate?(location = nil)
      if (location)
        (@mega_displays[0].dig(:collection_settings)&.pagination_position == location || @mega_displays[0].dig(:collection_settings)&.pagination_position == 'both') && !@mega_instance.blank?
      else 
        !@mega_displays[0].dig(:collection_settings)&.pagination_position.blank? && !@mega_instance.blank?
      end
    end
    
    def might_filter?(location = nil)
      if (location)
        (@mega_displays[0].dig(:collection_settings)&.pagination_position == location || @mega_displays[0].dig(:collection_settings)&.pagination_position == 'both') && !@mega_instance.blank?
      else 
        @mega_displays[0].dig(:collection_settings)&.filter_fields && !@mega_instance.blank?
      end
    end
    def num_per_page
      @mega_displays[0].dig(:collection_settings)&.records_per_page.blank? ? 6  : @mega_displays[0].dig(:collection_settings)&.records_per_page
    end

    def process_filters(mega_instance)
      if params["commit"] == "clear_filters"
        session[:mega_filters] = {}
      end
      session[:mega_filters] ||= {}
      return mega_instance unless params[@kontroller_inst] || session[:mega_filters][@kontroller_inst] 
      #cache me.
      if params[@kontroller_inst] 
        session[:mega_filters] = {}
        filter_types = MegaBar::Field.includes(:options).find_by(field: 'filter_type', tablename: 'mega_bar_fields').options.pluck(:value)
        filters = session[:mega_filters][@kontroller_inst.to_sym] = collect_filters(filter_types)
      elsif session[:mega_filters][@kontroller_inst]
         filters = session[:mega_filters][@kontroller_inst]
      end
      return mega_instance if filters.blank?
      @filter_text = []
      filters.each do |key, filt| 
        case key
        when 'contains'
          filt.each do | hsh |
            hsh.each do | field, value | 
              @filter_text << "#{field} contains #{value}" unless value.blank?
              mega_instance = mega_instance.where(field + " like ?", "%" + value + "%")
            end
          end
        end
        # $50 bounty for each additional case.
      end
      mega_instance
    end

    def collect_filters(filter_types)
      filters = Hash[filter_types.map {|v| [v, []] }]
      params[@kontroller_inst].each do |key, value|
        @mega_displays.each do |md|
          md[:displayable_fields].each do |df|
            filters[ df[:field].filter_type] <<  { df[:field].field => value } if !df[:field].filter_type.blank? && key.sub('___filter', '') == df[:field].field 
            # @mega_displays[0][:displayable_fields][0][:field].filter_type
          end
        end
      end
      filters
    end

    def constant_from_controller(str)
      logger.info("str::::" + str)
      constant_string = ''
      str.split('/').each_with_index do | seg, i |
        constant_string +=  i < str.split('/').size - 1 ? seg.classify + '::' : seg.classify
      end
      logger.info("constant string" + constant_string)
      constant_string
    end
    def column_sorting
      sort_column(@mega_class, @mega_model_properties, params) + " " + sort_direction(params, @mega_model_properties)
    end
    def redo_setup(action)
      env[:mega_rout][:action] = action
      env[:mega_env] = MegaEnv.new(@block, env[:mega_rout], env[:mega_page], []).to_hash
      set_vars_for_all
      set_vars_for_displays
      params[:action] = 'edit'
      params[:redo] = true
      @form_instance_vars = @nested_instance_variables  + [@mega_instance]
      'hello'
    end

    def move
      if ["move_lower", "move_higher", "move_to_top", "move_to_bottom"].include?(params[:method]) and @mega_rout[:id] =~ /^\d+$/
        @mega_class.find(@mega_rout[:id]).send(params[:method])
      end
      session[:return_to] ||= request.referer
      respond_to do |format|
        format.html { redirect_to session.delete(:return_to), notice: 'Thing was successfully mooved.' }
      end
    end
  end
end
