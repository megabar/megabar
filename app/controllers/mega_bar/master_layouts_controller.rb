module MegaBar 
  class MasterLayoutsController < ActionController::Base
    def render_layout_with_blocks
      @blocks = env['mega_final_blocks']
      render
   end
  end
end 
