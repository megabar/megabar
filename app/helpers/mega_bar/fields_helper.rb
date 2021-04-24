module MegaBar
  module FieldsHelper
    def pre_render
      if params[:action] == 'edit'
        # these are for some virtual attributes.
        @index_field_display = FieldDisplay.by_fields(@model.id).by_action('index').present?
        @show_field_display = FieldDisplay.by_fields(@model.id).by_action('show').present?
        @new_field_display = FieldDisplay.by_fields(@model.id).by_action('new').present?
        @edit_field_display = FieldDisplay.by_fields(@model.id).by_action('edit').present?
      end
    end
  end
end
