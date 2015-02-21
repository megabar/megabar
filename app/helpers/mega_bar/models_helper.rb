module MegaBar
  module ModelsHelper
    def pre_render
      byebug
      if @mega_action == 'edit' 
        # these are for viratual attributes
        @index_model_display = ModelDisplay.by_model(@model.id).by_action('index').present? ? 'y':'' 
        @show_model_display = ModelDisplay.by_model(@model.id).by_action('show').present? ? 'y':'' 
        @new_model_display = ModelDisplay.by_model(@model.id).by_action('new').present? ? 'y':'' 
        @edit_model_display = ModelDisplay.by_model(@model.id).by_action('edit').present? ? 'y':'' 
      end
    end
  end
end
