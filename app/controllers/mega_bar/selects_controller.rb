module MegaBar
  class SelectsController < ApplicationController
    include MegaBarConcern
    before_action ->{ myinit 8 },  only: [:index, :show, :edit, :new]

    private 
      def _params
        params.require(:textread).permit(:field_display_id, :model, :field, :collection, :value_method, :text_method, :data_size, :include_blank)
      end

  end
end
