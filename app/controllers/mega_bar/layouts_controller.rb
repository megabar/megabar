module MegaBar 
  class LayoutsController < MegaBar::ApplicationController
    include MegaBar::MegaBarConcern
    before_filter :conditions

    def conditions
      byebug
      @conditions.merge!(page_id: 12)
    end
  end
end 
