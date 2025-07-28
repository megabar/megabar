
module MegaBar


class DatesController < MegaBar::ApplicationController
    include MegaBar::MegaBarConcern
    include MegaBar::AuthorizationConcern
end


end 
