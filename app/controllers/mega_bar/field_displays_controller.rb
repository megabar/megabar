module MegaBar
  class FieldDisplaysController < ApplicationController
    include MegaBarConcern


    private
        # Never trust parameters from the scary internet, only allow the white list through.
    def _params
      params.require(:field_display).permit(:field_id, :format, :action, :header)
    end
  end
end
