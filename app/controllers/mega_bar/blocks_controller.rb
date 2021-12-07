module MegaBar 
  class BlocksController < MegaBar::ApplicationController
    include MegaBar::MegaBarConcern
    
    def new
      @layout_id = params["layout_id"] if params["layout_id"]
      @layout_section_id =  params["layout_section_id"] if params["layout_section_id"]
      super
    end

    def edit
      @mega_instance = Block.find(params["id"])

      @mega_displays[0][:displayable_fields].reject! do | df | 
        case df[:field].field
        when 'index_model_display'
          true if @mega_instance.model_displays.pluck(:action).include?'index'
        when 'show_model_display'
         true if @mega_instance.model_displays.pluck(:action).include?'show'
        when 'edit_model_display'
         true if @mega_instance.model_displays.pluck(:action).include?'edit'
        when 'new_model_display'
         true if @mega_instance.model_displays.pluck(:action).include?'new'
        else 
          false
        end
      end
      super
    end


    def get_options
      models = Model.all.pluck("name, id")
      @options[:mega_bar_blocks] =  {
        model_id: models,
        nest_level_1: models,
        nest_level_2: models,
        nest_level_3: models,
        nest_level_4: models,
        nest_level_5: models,
        nest_level_6: models,
        theme_ids: Theme.all.pluck("name, id"),
        site_ids: Site.all.pluck("name, id"),
        layout_section_id: LayoutSection.all.pluck("code_name, id"),
        permListAndView: PermissionLevel.all.pluck("level_name, level"),
        permCreateAndNew: PermissionLevel.all.pluck("level_name, level"),
        permEditAndSave: PermissionLevel.all.pluck("level_name, level"),
        permDelete: PermissionLevel.all.pluck("level_name, level"),
      }
    end


  end
end
