module MegaBar
  class FieldsController < ApplicationController
    include MegaBarConcern

    def get_options
      @options[:mega_bar_fields] =  {
       model_id: Model.all.pluck("name, id"), 
       tablename: Model.all.pluck("tablename, tablename") 
     } 
    end
  end
end
