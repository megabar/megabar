module MegaBar
  class ThemesController < MegaBar::ApplicationController
    include MegaBar::MegaBarConcern
    include MegaBar::AuthorizationConcern   
  end
end 
