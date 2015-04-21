module MegaBar 
  class PagesController < MegaBar::ApplicationController
    include MegaBar::MegaBarConcern   

    def index
      @conditions.merge!({"id" => 18..1000})
      super.index
    end

  end
end 
