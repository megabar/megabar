module MegaBar 
  class LayoutsController < MegaBar::ApplicationController
    include MegaBar::MegaBarConcern
    before_filter :conditions

    def conditions

      @conditions.merge!(env[:mega_env][:nested_ids][0]) if env[:mega_env][:nested_ids][0] 
    end
    def get_options
      @options[:mega_bar_layouts] =  {
        page_id: Page.all.pluck("name, id")
      }
    end
  end
end