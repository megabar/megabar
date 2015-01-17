module MegaBar
  class TextboxesController < ApplicationController
    include MegaBarConcern
   
    private
      # Never trust parameters from the scary internet, only allow the white list through.
      def _params
        params.require(:textbox).permit(:field_display_id, :size)
      end
  end
end