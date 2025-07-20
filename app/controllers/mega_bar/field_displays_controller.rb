module MegaBar
  class FieldDisplaysController < ApplicationController
    include MegaBarConcern
    include MegaBar::AuthorizationConcern
    # before_action -> { get_options },  only: [:index, :show, :edit, :new]  
  end
end