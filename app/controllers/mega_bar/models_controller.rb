module MegaBar
  class ModelsController < ApplicationController
    include MegaBarConcern


    def index
      @conditions.merge!({"id" => 22..1000})
      super.index
    end

    def get_options
      @options[:mega_bar_models] =  {
        default_sort_field: Field.by_model(params[:id]).pluck("field, id")
      } 
    end
  end
end