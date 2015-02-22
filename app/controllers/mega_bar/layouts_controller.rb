module MegaBar 
  class LayoutsController < MegaBar::ApplicationController
    include MegaBar::MegaBarConcern
    before_filter :conditions

    def conditions
      @conditions.merge!(page_id: 10)
    end
    def get_options
      @options[:mega_bar_layouts] =  {
        page_id: Page.all.pluck("name, id")
      }
    end
  end
end