module MegaBar
  class MasterPagesController < ActionController::Base
    def render_page
      @page_layouts = env["mega_final_layouts"]
      @mega_page = env[:mega_page]
      @mega_site = env[:mega_site]
      @mega_user = env[:mega_user]
      @page_classes = page_classes
      @site_name = site_name
      session[:admin_pages] ||= []

      render
    end

    def env
      request.env
    end

    def page_admin_link
      admin_text = ""

      if page_admin?
        admin_text = administering_page? ? "Turn off Admin for " : "Administer "
        if request.env[:mega_env].present?
          ActionController::Base.helpers.link_to "#{admin_text} #{@mega_page[:name]} Page", "#{request.env[:mega_page][:page_path]}/administer-page/#{@mega_page[:page_id].to_s}"
        else
          link = ["/mega-bar/pages/" + @mega_page[:page_id].to_s + "/layouts/" + request.env[:mega_layout].id.to_s + "?return_to=" + request.env["PATH_INFO"], "Layout Settings"] unless @mega_page.blank?
          ActionController::Base.helpers.link_to link[1], link[0]
        end
      end
    end

    helper_method :page_admin_link, :administering_page?

    def administering_page?
      session[:admin_pages].include?(@mega_page[:page_id].to_s)
    end

    def page_admin?
      
      return true if @mega_page[:administrator].blank? # this line should ultimately go away.

      @mega_user.pll >= @mega_page[:administrator]
    end

    helper_method :page_admin?

    def page_classes
      [portfolio_class, page_class, site_class, theme_class, "megabar_site_body"].compact.join(" ")
    end

    def portfolio_class
      return "base-portfolio" unless env[:mega_site].try(:portfolio).try(:code_name)

      env[:mega_site]&.portfolio&.code_name + "-portfolio"
    end

    def page_class
      return "home-page" if @mega_page[:page_path] == "/"
      @mega_page[:page_path].gsub("/", "__").gsub(":", "").downcase[2..-1] + "-page"
    end

    def site_class
      return "base-site" unless env[:mega_site].try(:code_name)

      env[:mega_site]&.code_name + "-site"
    end

    def site_name
      return "Base Site" unless env[:mega_site].try(:name)
      env[:mega_site]&.name
    end

    def theme_class
      return "base-theme" unless env[:mega_site].try(:theme)

      env[:mega_site]&.theme&.code_name + "-theme"
    end
  end
end
