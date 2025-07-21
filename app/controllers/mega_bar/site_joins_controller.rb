
module MegaBar 


class SiteJoinsController < MegaBar::ApplicationController
    include MegaBar::MegaBarConcern    
    include MegaBar::AuthorizationConcern
end


end 
