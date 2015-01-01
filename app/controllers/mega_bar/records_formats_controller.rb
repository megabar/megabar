module MegaBar
  class RecordsFormatsController < ApplicationController
    include MegaBarConcern
    before_action ->{ myinit 5 },  only: [:index, :show, :edit, :new]
    private 
    def _params
      params.require(:records_format).permit(:name, :classname, :type)
    end
  end
end