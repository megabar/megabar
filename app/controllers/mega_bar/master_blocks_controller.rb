module MegaBar
  class MasterBlocksController < ActionController::Base
    def render_flat_html_block
      #tbd
      byebug # you shouldnt be here.
      render
    end
    def env
      request.env
    end


  end
end
