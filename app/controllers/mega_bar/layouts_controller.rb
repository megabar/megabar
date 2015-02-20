module MegaBar 
  class LayoutsController < MegaBar::ApplicationController
    include MegaBar::MegaBarConcern
    before_filter :conditions

    def conditions
      @conditions.merge!(page_id: 10)
    end
  end
end 
