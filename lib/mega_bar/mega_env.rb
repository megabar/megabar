module MegaBar
  class MegaEnv
    attr_writer :mega_model_properties, :mega_displays, :nested_ids
    attr_reader :block, :modle, :modle_id, :mega_model_properties, :klass, :kontroller_inst, :kontroller_path, :kontroller_klass, :mega_displays, :nested_ids, :block_action, :params_hash_arr, :nested_class_info

    def initialize(blck, rout, page_info, pagination, user = nil)
      @user = user
      @block_model_displays = MegaBar::ModelDisplay.by_block(blck.id)
      @displays = blck.actions == "current" ? @block_model_displays.by_block(blck.id).by_action(rout[:action]) : @block_model_displays.by_block(blck.id)
      @block_action = @displays.empty? ? rout[:action] : @displays.first.action
      @modle = MegaBar::Model.by_model(@block_model_displays.first.model_id).first
      @modle_id = @modle.id
      @modyule = @modle.modyule.empty? ? "" : @modle.modyule + "::"
      @kontroller_klass = @modyule + @modle.classname.classify.pluralize + "Controller"
      @kontroller_path = build_kontroller_path
      @klass = (@modyule + @modle.classname.classify).constantize
      @kontroller_inst = @modle.classname.underscore
      @mega_displays = set_mega_displays(@displays)
      @nested_ids, @params_hash_arr, @nested_classes = nest_info(blck, rout, page_info)
      @nested_class_info = set_nested_class_info(@nested_classes)
      @block = blck
      @page_number = pagination.map { |info| info[:page].to_i if info[:kontrlr] == @kontroller_inst + "_page" }.compact.first
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

    private

    def build_kontroller_path
      if @modle.modyule.nil? || @modle.modyule.empty?
        @modle.classname.pluralize.underscore
      else
        @modyule.split("::").map { |m| m.underscore }.join("/") + "/" + @modle.classname.pluralize.underscore
      end
    end

    def set_mega_displays(displays)
      displays.map do |display|
        {
          model_display_format: find_model_display_format(display),
          displayable_fields: build_displayable_fields(display),
          model_display: display,
          collection_settings: find_collection_settings(display)
        }
      end
    end

    def find_model_display_format(display)
      display.authorized = check_display_authorization(display)
      MegaBar::ModelDisplayFormat.find(display.format)
    end

    def check_display_authorization(display)
      return true unless display.permission_level
      @user.pll >= display.permission_level
    end

    def find_collection_settings(display)
      return nil unless display.collection_or_member == "collection"
      MegaBar::ModelDisplayCollection.by_model_display_id(display.id).first
    end

    def build_displayable_fields(display)
      field_displays = MegaBar::FieldDisplay.by_model_display_id(display.id).order("position asc")
      field_displays.map do |field_disp|
        build_field_display_info(field_disp)
      end.compact
    end

    def build_field_display_info(field_disp)
      field = MegaBar::Field.find(field_disp.field_id)
      return nil unless is_displayable?(field_disp.format)

      {
        field_display: field_disp,
        field: field,
        data_format: find_data_format(field_disp),
        options: find_field_options(field_disp, field),
        obj: @mega_instance
      }
    end

    def find_data_format(field_disp)
      Object.const_get("MegaBar::" + field_disp.format.classify)
            .by_field_display_id(field_disp.id)
            .last
    end

    def find_field_options(field_disp, field)
      return nil unless field_disp.format == "select"
      MegaBar::Option.where(field_id: field.id).collect { |o| [o.text, o.value] }
    end

    def nest_info(blck, rout, page_info)
      return handle_path_based_nesting(blck, page_info) if blck.path_base.present?
      handle_simple_nesting(blck, rout)
    end

    def handle_path_based_nesting(blck, page_info)
      return [[], [], []] unless page_info[:page_path].starts_with?(blck.path_base) || blck.path_base.starts_with?(page_info[:page_path])
      
      params_hash_arr = []
      nested_ids = []
      nested_classes = []
      block_path_vars = blck.path_base.split("/").map { |m| m if m[0] == ":" } - ["", nil]
      
      (0..block_path_vars.size).each do |depth|
        blck_model = depth == 0 ? modle : MegaBar::Model.find(blck.send("nest_level_#{depth}"))
        fk_field = depth == 0 ? "id" : blck_model.classname.underscore.downcase + "_id"
        new_hash = { fk_field => page_info[:vars][block_path_vars.size - depth] }
        
        params_hash_arr << new_hash
        nested_ids << new_hash if depth > 0
        nested_classes << blck_model
      end
      
      [nested_ids, params_hash_arr, nested_classes]
    end

    def handle_simple_nesting(blck, rout)
      params_hash_arr = []
      nested_ids = []
      
      if rout[:id] && blck.nest_level_1.nil?
        params_hash_arr << { id: rout[:id] }
      else
        params_hash_arr << { id: nil }
      end
      
      if blck.nest_level_1.present?
        model = MegaBar::Model.find(blck.nest_level_1)
        nested_hash = { model.classname.underscore + "_id" => rout[:id] }
        params_hash_arr << nested_hash
        nested_ids << nested_hash
      end
      
      [nested_ids, params_hash_arr, []]
    end

    def set_nested_class_info(nested_classes)
      nested_classes.each_with_index.map do |nc, idx|
        next if idx == 0
        modyule = nc.modyule.empty? ? "" : nc.modyule + "::"
        [modyule + nc.classname.classify, nc.classname.underscore]
      end.compact
    end

    def is_displayable?(format)
      !["hidden", "off"].include?(format)
    end

    def authorized?
      required = case @block_action
        when "index", "show", "all"
          @block.permListAndView
        when "edit", "update"
          @block.permEditAndSave
        when "create", "new"
          @block.permCreateAndNew
        else
          nil
      end
      required.present? ? required <= @user.pll : true
    end

    def get_authorizations(page_info)
      {
        createAndNew: check_authorization(@block.permCreateAndNew),
        listAndView: check_authorization(@block.permListAndView),
        editAndSave: check_authorization(@block.permEditAndSave),
        delete: check_authorization(@block.permDelete),
        block_administrator: check_authorization(@block.administrator),
        page_administrator: check_authorization(page_info[:administrator])
      }
    end

    def check_authorization(permission_level)
      return true unless permission_level.present?
      @user.pll >= permission_level
    end
  end
end 