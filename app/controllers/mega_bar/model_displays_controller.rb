module MegaBar
  class ModelDisplaysController < ApplicationController
    include MegaBarConcern

    private
      # Never trust parameters from the scary internet, only allow the white list through.
      def _params
        params.require(:model_display).permit(:model_id, :format, :action, :header)
      end
  end
end