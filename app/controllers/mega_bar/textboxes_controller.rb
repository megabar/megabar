module MegaBar
  class TextboxesController < ApplicationController
    include MegaBarConcern
    def new
      @field_display_id = params["field_display_id"] if params["field_display_id"]
      super
    end
  end
end
