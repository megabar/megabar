
module MegaBar 
  class SitesController < MegaBar::ApplicationController
    include MegaBar::MegaBarConcern

    def get_options
      @options[:mega_bar_sites] =  {
        portfolio_id: Portfolio.all.pluck("name, id"),
        theme_id: Theme.all.pluck("name, id")
      }
    end 
  end
end 
