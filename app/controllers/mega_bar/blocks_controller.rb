module MegaBar 
  class BlocksController < MegaBar::ApplicationController
    include MegaBar::MegaBarConcern
    
    def new
      @layout_id = params["layout_id"] if params["layout_id"]
      super
    end
    def get_options
      models = Model.all.pluck("name, id")
      @options[:mega_bar_blocks] =  {
        model_id: models,
        nest_level_1: models,
        nest_level_2: models,
        nest_level_3: models,
        nest_level_4: models,
        nest_level_5: models,
        nest_level_6: models
      }
    end


  end
end
