module MegaBar
  class FieldDisplaysController < ApplicationController
    include MegaBarConcern
     before_action ->{ myinit 4 },  only: [:index, :show, :edit, :new]
     private
        # Never trust parameters from the scary internet, only allow the white list through.
    def _params
      params.require(:field_display).permit(:field_id, :format, :action, :header)
    end
  end
end
