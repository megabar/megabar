module MegaBar
  class SelectsController < ApplicationController
    include MegaBarConcern
 
    private 
      def _params
        params.require(:textread).permit(:field_display_id, :model, :field, :collection, :value_method, :text_method, :data_size, :include_blank)
      end

  end
end
