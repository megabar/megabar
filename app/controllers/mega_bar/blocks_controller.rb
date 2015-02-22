module MegaBar 
  class BlocksController < MegaBar::ApplicationController
    include MegaBar::MegaBarConcern

    def get_options
      @options[:mega_bar_blocks] =  {
        model_id: Model.all.pluck("name, id")
      }
    end


  end
end