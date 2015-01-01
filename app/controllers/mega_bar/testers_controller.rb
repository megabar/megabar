module MegaBar
  class TestersController < ApplicationController
    include MegaBarConcern
    before_action ->{ myinit 12 },  only: [:index, :show, :edit, :new]

    private 
      def _params
        params.require(:tester).permit(:one, :two, :three, :four)
      end
  end
end