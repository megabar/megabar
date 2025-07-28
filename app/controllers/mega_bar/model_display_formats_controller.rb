module MegaBar
  class ModelDisplayFormatsController < MegaBar::ApplicationController
    include MegaBar::MegaBarConcern
    include MegaBar::AuthorizationConcern
  end
end
