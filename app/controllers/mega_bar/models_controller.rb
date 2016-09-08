module MegaBar
  class ModelsController < ApplicationController
    include MegaBarConcern

    def index
      @mega_instance ||= Model.where.not(modyule: 'MegaBar').order(column_sorting)
      super.index
    end
    def all
      @mega_instance = Model.all.order(column_sorting) # .page(@page_number).per(5)
      index
    end


    def get_options

      @options[:mega_bar_models] =  {
        position_parent: MegaBar::Model.all.pluck(:name, :modyule, :classname).map{|a|  [a[1] + ' - ' + a[0], a[1] +'::' +  a[2]] }.unshift(['Position with No Parent', 'pnp']),
        default_sort_field: Field.by_model(params[:id]).pluck("field, field"),        
      }
    end
  end
end
