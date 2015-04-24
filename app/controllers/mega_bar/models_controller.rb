module MegaBar
  class ModelsController < ApplicationController
    include MegaBarConcern


    def index
      @mega_instance = Model.where(['id > ?', 21]).order(sort_stuff)
      super.index
    end

    def get_options
      @options[:mega_bar_models] =  {
        default_sort_field: Field.by_model(params[:id]).pluck("field, id")
      }
    end
  end
end
