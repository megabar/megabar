module MegaBar
  class MasterLayoutsController < ActionController::Base
    def render_layout_with_sections
      @mega_layout_sections ||= env['mega_final_layout_sections']
      @mega_layout ||= env[:mega_layout]
      @mega_page = env[:mega_page]
      template = Template.find(@mega_layout[:template_id])
      render template.code_name
    end

    def env
      request.env
    end

    def page_admin?
      session[:admin_pages].include?(@mega_page[:page_id].to_s)
    end
    helper_method :page_admin?

  end
end
