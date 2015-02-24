module MegaBar
  class ModelDisplaysController < ApplicationController
    include MegaBarConcern
   
    def get_options
      @options[:mega_bar_model_displays] =  {
        model_id: Model.all.pluck("name, id")
      } 
    end



  end
end