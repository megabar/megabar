module MegaBar
  class MasterPagesController < ActionController::Base
    def render_page
      @page_layouts = env['mega_final_layouts']
      @mega_page = env[:mega_page]
      @page_class = @mega_page[:page_path].gsub('/', '__').gsub(':', '').underscore.downcase[2..-1]
      render
    end

    def env
      request.env
    end

  end
end
