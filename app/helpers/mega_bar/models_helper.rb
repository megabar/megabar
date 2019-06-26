module MegaBar
  module ModelsHelper
    def pre_render
      if params[:action] == 'edit'
        # these are for viratual attributes
        @index_model_display = ModelDisplay.by_model(@model.id).by_action('index').present?
        @show_model_display = ModelDisplay.by_model(@model.id).by_action('show').present?
        @new_model_display = ModelDisplay.by_model(@model.id).by_action('new').present?
        @edit_model_display = ModelDisplay.by_model(@model.id).by_action('edit').present?
      end
    end
  end
end
