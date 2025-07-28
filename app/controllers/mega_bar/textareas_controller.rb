module MegaBar
  class TextareasController < MegaBar::ApplicationController
    include MegaBar::MegaBarConcern
    include MegaBar::AuthorizationConcern

    def new
      @field_display_id = params["field_display_id"] if params["field_display_id"]
      super
    end
  end
end 
