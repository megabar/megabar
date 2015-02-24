module MegaBar 
  class LayoutsController < MegaBar::ApplicationController
    include MegaBar::MegaBarConcern
    
    def get_options
      @options[:mega_bar_layouts] =  {
        page_id: Page.all.pluck("name, id")
      }
    end
  end
end