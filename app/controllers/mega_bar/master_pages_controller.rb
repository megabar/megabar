module MegaBar 
  class MasterPagesController < ActionController::Base
    def render_page
      @page_layouts = env['mega_final_layouts']
      render
   end
  end
end 
