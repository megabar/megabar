module MegaBar 
  class OptionsController < MegaBar::ApplicationController
    include MegaBar::MegaBarConcern
    def new
      @field_id = params["field_id"] if params["field_id"]
      super
    end
  end
end 
