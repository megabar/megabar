module MegaBar
  module RequestProcessing
    def static_asset?(env)
      env["PATH_INFO"].end_with?(".sass", ".css", ".js", ".jpeg", ".jpg", ".json")
    end

    def handle_static_assets(env)
      @status, @headers, @response = @app.call(env)
      [@status, @headers, self]
    end

    def setup_request_environment(env)
      env["REQUEST_METHOD"] = "PATCH" if env["REQUEST_METHOD"] == "PUT"
      @redirect = false
      
      request = Rack::Request.new(env)
      request.params # needed for best_in_place updates
      
      setup_site(request, env)
      setup_session(request, env)
      setup_routing(request, env)
    end

    def setup_site(request, env)
      site = MegaBar::Site.where(domains: request.host).first
      env[:mega_site] = site.present? ? site : MegaBar::Site.where(domains: "base").first
    end

    def setup_session(request, env)
      request.session[:return_to] = env["rack.request.query_hash"]["return_to"] unless env["rack.request.query_hash"]["return_to"].blank?
      request.session[:return_to] = nil if env["rack.request.query_hash"]["method"].present?
      request.session[:init] = true
      request.session[:admin_pages] ||= []
    end

    def setup_routing(request, env)
      rout_terms = request.path_info.split("/").reject! { |c| (c.nil? || c.empty?) }
      env[:mega_rout] = set_rout(request, env)
      env[:mega_page] = set_page_info(env[:mega_rout], rout_terms)
      env[:mega_pagination] = set_pagination_info(env, rout_terms)
    end



    def handle_non_megabar_page(env)
      rout = env[:mega_rout]
      puts "🔍 DEBUG: handle_non_megabar_page - rout: #{rout.inspect}"
      puts "🔍 DEBUG: handle_non_megabar_page - PATH_INFO: #{env['PATH_INFO']}"
      puts "🔍 DEBUG: handle_non_megabar_page - REQUEST_METHOD: #{env['REQUEST_METHOD']}"
      
      # If we have a recognized route, let Rails handle it normally
      if rout[:controller].present? && rout[:action].present?
        puts "🔍 DEBUG: Recognized route: #{rout[:controller]}##{rout[:action]}"
        puts "🔍 DEBUG: Falling back to Rails routing for recognized route"
        return @app.call(env)
      end
      
      # Default fallback for unrecognized routes
      rout[:controller] ||= "flats"
      rout[:action] ||= "index"
      
      puts "🔍 DEBUG: handle_non_megabar_page called"
      puts "🔍 DEBUG: rout = #{rout.inspect}"
      puts "🔍 DEBUG: PATH_INFO = #{env['PATH_INFO']}"
      puts "🔍 DEBUG: REQUEST_METHOD = #{env['REQUEST_METHOD']}"
      
      # Check if the controller and action actually exist
      controller_name = (rout[:controller].classify.pluralize + "Controller")
      puts "🔍 DEBUG: controller_name = #{controller_name}"
      
      begin
        controller_class = controller_name.constantize
        puts "🔍 DEBUG: controller_class = #{controller_class}"
        puts "🔍 DEBUG: available methods = #{controller_class.instance_methods.grep(/^#{rout[:action]}$/)}"
        
        if controller_class.instance_methods.include?(rout[:action].to_sym)
          puts "🔍 DEBUG: Action exists, processing normally"
          # Controller and action exist, process normally
          @status, @headers, @page = controller_class.action(rout[:action]).call(env)
          page_content = @page.blank? ? "" : @page.body.html_safe
          [@status, @headers, [page_content]]
        else
          puts "🔍 DEBUG: Action doesn't exist, falling back to Rails routing"
          # Action doesn't exist, fall back to normal Rails routing
          @app.call(env)
        end
      rescue NameError => e
        puts "🔍 DEBUG: Controller doesn't exist: #{e.message}"
        puts "🔍 DEBUG: Falling back to Rails routing"
        # Controller doesn't exist, fall back to normal Rails routing
        @app.call(env)
      rescue => e
        puts "🔍 DEBUG: Other error: #{e.class} - #{e.message}"
        puts "🔍 DEBUG: Falling back to Rails routing"
        @app.call(env)
      end
    end

    def set_rout(request, env)
      request_path_info = request.path_info.dup
      puts "🔍 DEBUG: set_rout - PATH_INFO: #{request_path_info}, METHOD: #{env['REQUEST_METHOD']}"
      
      rout = (Rails.application.routes.recognize_path request_path_info, method: env["REQUEST_METHOD"] rescue {}) || {}
      puts "🔍 DEBUG: set_rout - Rails routes result: #{rout.inspect}"
      
      rout = (MegaBar::Engine.routes.recognize_path request_path_info rescue {}) || {} if rout.empty? && request_path_info == "/mega-bar"
      rout = (MegaBar::Engine.routes.recognize_path request_path_info.sub!("/mega-bar/", ""), method: env["REQUEST_METHOD"] rescue {}) || {} if rout.empty?
      
      puts "🔍 DEBUG: set_rout - Final rout: #{rout.inspect}"
      rout
    end

    def set_page_info(rout, rout_terms)
      puts "🔍 DEBUG: set_page_info - rout: #{rout.inspect}, rout_terms: #{rout_terms.inspect}"
      result = MegaBar::PageInfoProcessor.new(rout, rout_terms).process
      puts "🔍 DEBUG: set_page_info - result: #{result.inspect}"
      result
    end

    def set_pagination_info(env, rout_terms)
      MegaBar::PaginationProcessor.new(env, rout_terms).process
    end

    private

    def extract_pagination_from_rout_terms(rout_terms)
      return [] unless rout_terms.present?
      
      rout_terms.map.with_index do |term, index|
        next unless term.match?(/_page$/)
        { kontrlr: term, page: rout_terms[index + 1] }
      end.compact
    end

    def extract_pagination_from_query_string(env)
      query_hash = Rack::Utils.parse_nested_query(env["QUERY_STRING"])
      query_hash.map do |key, value|
        next unless key.match?(/_page$/)
        { kontrlr: key, page: value }
      end.compact
    end
  end
end 