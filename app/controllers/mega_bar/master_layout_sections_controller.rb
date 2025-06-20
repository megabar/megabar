module MegaBar
  class MasterLayoutSectionsController < ActionController::Base
    def render_layout_section_with_blocks
      @blocks = env['mega_final_blocks']
      @mega_layout_section = env[:mega_layout_section]
      @mega_layout = env[:mega_layout]
      @mega_page = env[:mega_page]
      @tabs =  @blocks.select{|blck| blck[:actions] == 'show'}

      render
    end

    def render_layout_section_admin
      # If we're already rendering something, return a placeholder
      if performed?
        render plain: "<!-- Section Placeholder -->"
      else
        render 'render_layout_section_admin'
      end
    end

    def env
      request.env
    end

  end
end
