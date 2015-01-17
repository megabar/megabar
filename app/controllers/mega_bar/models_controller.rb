module MegaBar
  class ModelsController < ApplicationController
    include MegaBarConcern
    # attr_accessor :edit_model_display
    #before_action :app_init,  only: [:index, :show, :edit, :new]
    private
      # Never trust parameters from the scary internet, only allow the white list through.
    def _params
      # params.require(:model).permit(:model:classname, :schema, :tablename, :name)
      params.require(:model).permit(:classname, :schema, :tablename, :name, :default_sort_field, :index_model_display, :show_model_display, :new_model_display, :edit_model_display)
    end
  end
end