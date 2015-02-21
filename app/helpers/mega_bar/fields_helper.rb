module MegaBar
  module FieldsHelper
    def pre_render
      byebug
      if @mega_action == 'edit' 
        # these are for some virtual attributes.
        @index_field_display = FieldDisplay.by_fields(@model.id).by_action('index').present? ? 'y':'' 
        @show_field_display = FieldDisplay.by_fields(@model.id).by_action('show').present? ? 'y':'' 
        @new_field_display = FieldDisplay.by_fields(@model.id).by_action('new').present? ? 'y':'' 
        @edit_field_display = FieldDisplay.by_fields(@model.id).by_action('edit').present? ? 'y':'' 
      end
    end
  end
end
