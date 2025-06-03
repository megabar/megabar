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
      @kontroller_path = @modle.modyule.nil? || @modle.modyule.empty? ? @modle.classname.pluralize.underscore : @modyule.split("::").map { |m| m = m.underscore }.join("/") + "/" + @modle.classname.pluralize.underscore
      @klass = (@modyule + @modle.classname.classify).constantize
      meta_programming(@klass, @modle)
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

    def meta_programming(klass, modle)
      # position_parent_method = modle.position_parent.split("::").last.underscore.downcase.to_sym unless modle.position_parent.blank? || modle.position_parent == 'pnp'
      # klass.class_eval{ acts_as_list scope: position_parent_method, add_new_at: :bottom } if position_parent_method
    end

    def set_mega_displays(displays)
      mega_displays_info = [] # collects model and field display settings
      displays.each do |display|
        display.authorized = display.permission_level ? @user.pll >= display.permission_level ? true : false : true
        model_display_format = MegaBar::ModelDisplayFormat.find(display.format)
        model_display_collection_settings = MegaBar::ModelDisplayCollection.by_model_display_id(display.id).first if display.collection_or_member == "collection"
        field_displays = MegaBar::FieldDisplay.by_model_display_id(display.id).order("position asc")
        displayable_fields = []
        field_displays.each do |field_disp|
          field = MegaBar::Field.find(field_disp.field_id)
          if is_displayable?(field_disp.format)
            data_format = Object.const_get("MegaBar::" + field_disp.format.classify).by_field_display_id(field_disp.id).last #data_display models have to have this scope!
            if field_disp.format == "select"
              options = MegaBar::Option.where(field_id: field.id).collect { |o| [o.text, o.value] }
            end
            displayable_fields << { field_display: field_disp, field: field, data_format: data_format, options: options, obj: @mega_instance }
          end
        end
        info = {
          :model_display_format => model_display_format,
          :displayable_fields => displayable_fields,
          :model_display => display,
          :collection_settings => model_display_collection_settings,
        }
        mega_displays_info << info
      end
      mega_displays_info
    end

    def nest_info(blck, rout, page_info)
      params_hash_arr = []
      nested_ids = []
      nested_classes = []
      puts "================="
      puts blck, rout, page_info
      if blck.path_base.present?
        if page_info[:page_path].starts_with?(blck.path_base) || blck.path_base.starts_with?(page_info[:page_path])
          block_path_vars = blck.path_base.split("/").map { |m| m if m[0] == ":" } - ["", nil]
          depth = 0
          puts "bpv" + block_path_vars.to_s
          until depth == block_path_vars.size + 1
            blck_model = depth == 0 ? modle : MegaBar::Model.find(blck.send("nest_level_#{depth}"))
            fk_field = depth == 0 ? "id" : blck_model.classname.underscore.downcase + "_id"
            new_hash = { fk_field => page_info[:vars][block_path_vars.size - depth] }
            params_hash_arr << new_hash
            nested_ids << new_hash if depth > 0
            nested_classes << blck_model
            depth += 1
          end
        end
      else
        params_hash_arr << h = (rout[:id] && blck.nest_level_1.nil?) ? { id: rout[:id] } : { id: nil }
        params_hash_arr << i = { MegaBar::Model.find(blck.nest_level_1).classname.underscore + "_id" => rout[:id] } if !blck.nest_level_1.nil?
        nested_ids << i if i
      end
      return nested_ids, params_hash_arr, nested_classes
    end

    def set_nested_class_info(nested_classes)
      nested_class_info = []
      nested_classes.each_with_index do |nc, idx|
        modyule = nc.modyule.empty? ? "" : nc.modyule + "::"
        klass = modyule + nc.classname.classify
        nested_class_info << [klass, nc.classname.underscore] if idx != 0
      end
      nested_class_info
    end

    def is_displayable?(format)
      return (format == "hidden" || format == "off") ? false : true
    end

    def authorized?
      puts "hmm"
      required = case @block_action
        when "index", "show", "all"
          @block.permListAndView
        when "edit", "update"
          @block.permEditAndSave
        when "create", "new"
          @block.permCreateAndNew
        else
          # tbd for custom actions.
        end
      required.present? ? required <= @user.pll : true
    end

    def get_authorizations(page_info)
      {
        createAndNew: @block.permCreateAndNew.present? ? @user.pll >= @block.permCreateAndNew : true,
        listAndView: @block.permListAndView.present? ? @user.pll >= @block.permListAndView : true,
        editAndSave: @block.permEditAndSave.present? ? @user.pll >= @block.permEditAndSave : true,
        delete: @block.permDelete.present? ? @user.pll >= @block.permDelete : true,
        block_administrator: @block.administrator.present? ? @user.pll >= @block.administrator : true,
        page_administrator: page_info[:administrator].present? ? @user.pll >= page_info[:administrator] : true,
      }
    end
  end
end 