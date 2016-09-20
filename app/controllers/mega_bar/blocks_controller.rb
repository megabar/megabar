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
        nest_level_6: models,
        theme_ids: Theme.all.pluck("name, id"),
        site_ids: Site.all.pluck("name, id"),
        layout_section_id: LayoutSection.all.pluck("code_name, id")
      }
    end


  end
end
