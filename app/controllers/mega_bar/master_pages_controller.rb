module MegaBar 
  class MasterPagesController < ActionController::Base
    def render_page
      @page_layouts = env['mega_final_layouts']
      @mega_page = env[:mega_page]
      render
   end
  end
end 
