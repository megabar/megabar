module MegaBar 
  class LayoutsController < MegaBar::ApplicationController
    include MegaBar::MegaBarConcern
    
    def new
      @page_id = params["page_id"] if params["page_id"]
      super
    end
    def get_options
      @options[:mega_bar_layouts] =  {
        page_id: Page.all.pluck("name, id"),
        theme_ids: Theme.all.pluck("name, id"),
        template_id: Template.all.pluck("name, id"),
        site_ids: Site.all.pluck("name, id") # [['All But...', 0]] + 
      }
    end
  end
end
