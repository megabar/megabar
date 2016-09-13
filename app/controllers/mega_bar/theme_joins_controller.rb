module MegaBar 
  class ThemeJoinsController < MegaBar::ApplicationController
      include MegaBar::MegaBarConcern    

    def get_options
      @options[:mega_bar_theme_joins] =  {
        theme_id: Theme.all.pluck("name, id"),
        themeable_type: [['Layout', 'Layout'], ['Block', 'Block']]
      }
    end  
  end
end 
