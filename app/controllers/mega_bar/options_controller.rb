module MegaBar
  class OptionsController < MegaBar::ApplicationController
    include MegaBar::MegaBarConcern
    include MegaBar::AuthorizationConcern
    def new
      @field_id = params["field_id"] if params["field_id"]
      super
    end
  end
end 
