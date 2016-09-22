module MegaBar
  class ModelDisplaysController < ApplicationController
    include MegaBarConcern
   
    def get_options
      @options[:mega_bar_model_displays] =  {
        model_id: Model.all.pluck("name, id")
      } 
    end

    def edit
      @mega_instance = ModelDisplay.find(params["id"])
      @mega_displays[0][:displayable_fields].reject! do | df | 
        case df[:field].field
        when 'index_field_display', 'show_field_display', 'edit_field_display', 'new_field_display'
          true if isnt_current_action(df[:field].field) || @mega_instance.field_displays.present?
        else 
          false
        end
      end
      super
    end
  
    def isnt_current_action(field)

      case @mega_instance.action
      when 'show'
        true if field == 'show_field_display'
      when 'index' 
        true if field == 'index_field_display'
      when 'new' 
        true if field == 'new_field_display'
      when 'edit' 
        true if field == 'edit_field_display'
      else
        false
      end
    end
  end
end
