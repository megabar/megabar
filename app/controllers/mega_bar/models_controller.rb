module MegaBar
  class ModelsController < ApplicationController
    include MegaBarConcern

    def index
      # @mega_instance ||= Model.where.not(modyule: 'MegaBar').order(column_sorting)
      super.index
    end
    def all
      @mega_instance = Model.all.order(column_sorting).page(params[:model_page]).per(5)
      index
    end

    def get_options
      @options[:mega_bar_models] =  {
        default_sort_field: Field.by_model(params[:id]).pluck("field, field")
      }
    end
  end
end
