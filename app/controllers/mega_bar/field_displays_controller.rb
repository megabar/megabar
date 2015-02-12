module MegaBar
  class FieldDisplaysController < ApplicationController
    include MegaBarConcern
    # before_action -> { get_options },  only: [:index, :show, :edit, :new]  
  end
end