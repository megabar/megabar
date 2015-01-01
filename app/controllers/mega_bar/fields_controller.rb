module MegaBar
  class FieldsController < ApplicationController
    include MegaBarConcern
    before_action ->{ myinit 2 },  only: [:index, :show, :edit, :new]
    private
    # Never trust parameters from the scary internet, only allow the white list through.
    def _params
      params.require(:field).permit(:model_id, :schema, :tablename, :field, :default_value, :new_field_display, :edit_field_display, :index_field_display, :show_field_display)
    end
  end
end
