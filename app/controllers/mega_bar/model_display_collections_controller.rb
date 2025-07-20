module MegaBar
  class ModelDisplayCollectionsController < MegaBar::ApplicationController
    include MegaBar::MegaBarConcern
    include MegaBar::AuthorizationConcern  

    def new
      @model_display_id = params["model_display_id"] if params["model_display_id"]
      super
    end   
  end
end 
