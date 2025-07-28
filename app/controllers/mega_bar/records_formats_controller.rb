module MegaBar
  class RecordsFormatsController < ApplicationController
    include MegaBarConcern
    include MegaBar::AuthorizationConcern
  end
end