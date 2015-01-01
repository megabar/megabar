
module MegaBar
  class TmpTextreadsController < ApplicationController
    include MegaBarConcern
    before_action ->{ myinit 16 },  only: [:index, :show, :edit, :new]


    private
      def _params
        permits = []
        controller_name.classify.constantize.attribute_names.each do |att|
          permits << att unless ['id', 'created_at', 'updated_at'].include?(att)
        end
        params.require(controller_name.singularize).permit(permits)
      end

  end
end