module MegaBar
  class TextreadsController < ApplicationController
    include MegaBarConcern
    before_action ->{ myinit 7 },  only: [:index, :show, :edit, :new]
    private 
    def _params
      params.require(:textread).permit(:field_display_id, :truncation, :truncation_format, :transformation)
    end
  end
end
