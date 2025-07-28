module MegaBar
  class TextreadsController < ApplicationController
    include MegaBarConcern
    include MegaBar::AuthorizationConcern
    def new
      @field_display_id = params["field_display_id"] if params["field_display_id"]
      super
    end
  end
end
