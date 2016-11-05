module MegaBar 
  class PortfoliosController < MegaBar::ApplicationController
    include MegaBar::MegaBarConcern

    def get_options
      @options[:mega_bar_portfolios] =  {
        theme_id: Theme.all.pluck("name, id")
      }
    end
  end
end 
