module MegaBar
  class ModelsController < ApplicationController
    include MegaBarConcern

    def index
      admin_models = [21,20,18,17,15,14,7,6,4,3,2,1]
      @mega_instance ||= Model.where(['id not in (?)', admin_models ]).order(column_sorting)
      super.index
    end
    def all
      @mega_instance = Model.all.order(column_sorting)
      index
    end

    def get_options
      @options[:mega_bar_models] =  {
        default_sort_field: Field.by_model(params[:id]).pluck("field, field")
      }
    end
  end
end
