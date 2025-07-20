
module MegaBar


class ImageFromUrlsController < MegaBar::ApplicationController
    include MegaBar::MegaBarConcern
    include MegaBar::AuthorizationConcern
end


end 
