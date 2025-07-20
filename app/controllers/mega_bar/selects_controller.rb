module MegaBar
  class SelectsController < MegaBar::ApplicationController
    include MegaBar::MegaBarConcern
    include MegaBar::AuthorizationConcern    
  end
end
