
module MegaBar 


class DatesController < MegaBar::ApplicationController
    include MegaBar::MegaBarConcern    
    skip_before_action :check_authorization, only: [:index]

end


end 
