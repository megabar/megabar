module MegaBar
  class MasterLayoutsController < ActionController::Base
    def render_layout_with_sections
      @mega_layout_sections ||= env['mega_final_layout_sections']
      @mega_layout ||= env[:mega_layout]
      @mega_page = env[:mega_page]
      @mega_user = env[:mega_user]
      template = Template.find(@mega_layout[:template_id])
      render template.code_name
    end

    def env
      request.env
    end

    def administering_page?
      session[:admin_pages].include?(@mega_page[:page_id].to_s)
    end


    helper_method :administering_page?

  end
end
