module MegaBar
  # Enhanced MegaEnv class with improved error handling and cleaner code
  class MegaEnv
    attr_writer :mega_model_properties, :mega_displays, :nested_ids
    attr_reader :block, :modle, :modle_id, :mega_model_properties, :klass, :kontroller_inst, :kontroller_path, :kontroller_klass, :mega_displays, :nested_ids, :block_action, :params_hash_arr, :nested_class_info

    def initialize(block, route_info, page_info, pagination, user = nil)
      @user = user
      @block_model_displays = MegaBar::ModelDisplay.by_block(block.id)
      @displays = block.actions == "current" ? @block_model_displays.by_block(block.id).by_action(route_info[:action]) : @block_model_displays.by_block(block.id)
      @block_action = @displays.empty? ? route_info[:action] : @displays.first.action
      @modle = MegaBar::Model.by_model(@block_model_displays.first.model_id).first
      @modle_id = @modle.id
      @modyule = @modle.modyule.empty? ? "" : @modle.modyule + "::"
      @kontroller_klass = @modyule + @modle.classname.classify.pluralize + "Controller"
      @kontroller_path = build_kontroller_path
      @klass = (@modyule + @modle.classname.classify).constantize
      meta_programming(@klass, @modle)
      @kontroller_inst = @modle.classname.underscore
      @mega_displays = set_mega_displays(@displays)
      @nested_ids, @params_hash_arr, @nested_classes = nest_info(block, route_info, page_info)
      @nested_class_info = set_nested_class_info(@nested_classes)
      @block = block
      @page_number = extract_page_number(pagination)
      @authorized = authorized?
      @authorizations = get_authorizations(page_info)
    end

    def to_hash
      {
        block: @block,
        modle_id: @modle_id,
        mega_model_properties: @modle,
        klass: @klass,
        kontroller_inst: @kontroller_inst,
        kontroller_path: @kontroller_path,
        mega_displays: @mega_displays,
        nested_ids: @nested_ids,
        nested_class_info: @nested_class_info,
        page_number: @page_number,
        user: @user,
        authorized: @authorized,
        authorizations: @authorizations,
      }
    end

    def meta_programming(klass, modle)
      # Legacy method - kept for compatibility
    end

    def set_mega_displays(displays)
      mega_displays_info = []
      
      displays.each do |display|
        display.authorized = authorized_for_display?(display)
        
        model_display_format = MegaBar::ModelDisplayFormat.find(display.format)
        model_display_collection_settings = find_collection_settings(display)
        field_displays = MegaBar::FieldDisplay.by_model_display_id(display.id).order("position asc")
        displayable_fields = build_displayable_fields(field_displays)
        
        mega_displays_info << {
          model_display_format: model_display_format,
          displayable_fields: displayable_fields,
          model_display: display,
          collection_settings: model_display_collection_settings,
        }
      end
      
      mega_displays_info
    end

    def nest_info(block, route_info, page_info)
      params_hash_arr = []
      nested_ids = []
      nested_classes = []
      
      Rails.logger.debug "Processing nest info for block: #{block.id}"
      
      if block.path_base.present?
        process_path_based_nesting(block, page_info, params_hash_arr, nested_ids, nested_classes)
      else
        process_simple_nesting(block, route_info, params_hash_arr, nested_ids)
      end
      
      [nested_ids, params_hash_arr, nested_classes]
    end

    def set_nested_class_info(nested_classes)
      nested_classes.each_with_index.filter_map do |nested_class, index|
        next if index == 0  # Skip first class
        
        modyule = nested_class.modyule.empty? ? "" : nested_class.modyule + "::"
        klass = modyule + nested_class.classname.classify
        [klass, nested_class.classname.underscore]
      end
    end

    def is_displayable?(format)
      !%w[hidden off].include?(format)
    end

    def authorized?
      required_permission = case @block_action
                           when *LayoutEngine::READ_ACTIONS
                             @block.permListAndView
                           when *LayoutEngine::WRITE_ACTIONS
                             @block.permEditAndSave
                           when *LayoutEngine::CREATE_ACTIONS
                             @block.permCreateAndNew
                           end
      
      required_permission.present? ? required_permission <= @user.pll : true
    end

    def get_authorizations(page_info)
      {
        createAndNew: authorized_for_permission?(@block.permCreateAndNew),
        listAndView: authorized_for_permission?(@block.permListAndView),
        editAndSave: authorized_for_permission?(@block.permEditAndSave),
        delete: authorized_for_permission?(@block.permDelete),
        block_administrator: authorized_for_permission?(@block.administrator),
        page_administrator: authorized_for_permission?(page_info[:administrator]),
      }
    end

    private

    def build_kontroller_path
      if @modle.modyule.nil? || @modle.modyule.empty?
        @modle.classname.pluralize.underscore
      else
        module_path = @modyule.split("::").map(&:underscore).join("/")
        "#{module_path}/#{@modle.classname.pluralize.underscore}"
      end
    end

    def extract_page_number(pagination)
      pagination.filter_map do |info|
        info[:page].to_i if info[:kontrlr] == "#{@kontroller_inst}_page"
      end.first
    end

    def authorized_for_display?(display)
      return true unless display.permission_level
      @user.pll >= display.permission_level
    end

    def find_collection_settings(display)
      return nil unless display.collection_or_member == "collection"
      MegaBar::ModelDisplayCollection.by_model_display_id(display.id).first
    end

    def build_displayable_fields(field_displays)
      field_displays.filter_map do |field_disp|
        next unless is_displayable?(field_disp.format)
        
        field = MegaBar::Field.find(field_disp.field_id)
        data_format = find_data_format(field_disp)
        options = extract_options(field_disp, field)
        
        {
          field_display: field_disp,
          field: field,
          data_format: data_format,
          options: options,
          obj: @mega_instance
        }
      end
    end

    def find_data_format(field_disp)
      format_class = "MegaBar::#{field_disp.format.classify}"
      Object.const_get(format_class).by_field_display_id(field_disp.id).last
    rescue NameError => e
      Rails.logger.warn "Could not find data format class: #{format_class}"
      nil
    end

    def extract_options(field_disp, field)
      return nil unless field_disp.format == "select"
      MegaBar::Option.where(field_id: field.id).pluck(:text, :value)
    end

    def process_path_based_nesting(block, page_info, params_hash_arr, nested_ids, nested_classes)
      return unless path_matches_page?(block, page_info)
      
      block_path_vars = extract_path_variables(block.path_base)
      
      (0..block_path_vars.size).each do |depth|
        block_model = depth == 0 ? @modle : MegaBar::Model.find(block.send("nest_level_#{depth}"))
        fk_field = depth == 0 ? "id" : "#{block_model.classname.underscore}_id"
        
        value = page_info[:vars][block_path_vars.size - depth]
        new_hash = { fk_field => value }
        
        params_hash_arr << new_hash
        nested_ids << new_hash if depth > 0
        nested_classes << block_model
      end
    end

    def process_simple_nesting(block, route_info, params_hash_arr, nested_ids)
      # Simple one-level nesting without path_base
      id_value = route_info[:id] && block.nest_level_1.nil? ? route_info[:id] : nil
      params_hash_arr << { id: id_value }
      
      if block.nest_level_1
        nested_model = MegaBar::Model.find(block.nest_level_1)
        nested_hash = { "#{nested_model.classname.underscore}_id" => route_info[:id] }
        params_hash_arr << nested_hash
        nested_ids << nested_hash
      end
    end

    def path_matches_page?(block, page_info)
      page_path = page_info[:page_path]
      block_path = block.path_base
      
      page_path.starts_with?(block_path) || block_path.starts_with?(page_path)
    end

    def extract_path_variables(path_base)
      path_base.split("/").select { |segment| segment.starts_with?(":") } - ["", nil]
    end

    def authorized_for_permission?(permission_level)
      return true unless permission_level.present?
      @user.pll >= permission_level
    end
  end
end 