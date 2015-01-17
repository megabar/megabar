module MegaBar
  class TextreadsController < ApplicationController
    include MegaBarConcern
 
    private 
    def _params
      params.require(:textread).permit(:field_display_id, :truncation, :truncation_format, :transformation)
    end
  end
end
