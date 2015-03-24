module MegaBar 
  class MasterLayoutsController < ActionController::Base
    def render_layout_with_blocks
      @blocks = env['mega_final_blocks']
      @mega_layout = env[:mega_layout]
      @mega_page = env[:mega_page]
      render
   end
  end
end 
