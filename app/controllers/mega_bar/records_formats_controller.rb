module MegaBar
  class RecordsFormatsController < ApplicationController
    include MegaBarConcern
 
    private 
    def _params
      params.require(:records_format).permit(:name, :classname, :type)
    end
  end
end