module MegaBar 
  class CheckboxesController < MegaBar::ApplicationController
    include MegaBar::MegaBarConcern
    def new
      @field_display_id = params["field_display_id"] if params["field_display_id"]
      super
    end 
  end
end
