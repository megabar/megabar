
module MegaBar 


class RadiosController < MegaBar::ApplicationController
    include MegaBar::MegaBarConcern    
    include MegaBar::AuthorizationConcern
end


end 
