module MegaBar
  class RequestProcessor
    def initialize(app = nil)
      @app = app
    end

    def process(env)
      return handle_static_assets(env) if static_asset?(env["PATH_INFO"])
      return handle_json_request(env) if env["PATH_INFO"].end_with?(".json")

      env["REQUEST_METHOD"] = "PATCH" if env["REQUEST_METHOD"] == "PUT"
      
      request = setup_request(env)
      site = find_site(request)
      env[:mega_site] = site

      setup_session(request, env)
      setup_user(request, env)

      page_info = process_page_info(request, env)
      return handle_non_megabar_page(request, env) if page_info.empty?

      [env, page_info]
    end

    private

    def static_asset?(path_info)
      path_info.end_with?(".sass", ".css", ".js", ".jpeg", ".jpg")
    end

    def handle_static_assets(env)
      @app.call(env)
    end

    def handle_json_request(env)
      @app.call(env)
    end

    def setup_request(env)
      request = Rack::Request.new(env)
      request.params # needed for best_in_place updates
      request
    end

    def find_site(request)
      site = MegaBar::Site.where(domains: request.host).first
      site.present? ? site : MegaBar::Site.where(domains: "base").first
    end

    def setup_session(request, env)
      request.session[:return_to] = env["rack.request.query_hash"]["return_to"] unless env["rack.request.query_hash"]["return_to"].blank?
      request.session[:return_to] = nil if env["rack.request.query_hash"]["method"].present?
      request.session[:init] = true
      request.session[:admin_pages] ||= []
    end

    def setup_user(request, env)
      env[:mega_user] = if request.session["user_id"] && MegaBar::User.all.size > 0
        MegaBar::User.find(request.session["user_id"])
      else
        MegaBar::User.new
      end
    end

    def process_page_info(request, env)
      rout_terms = request.path_info.split("/").reject! { |c| (c.nil? || c.empty?) }
      env[:mega_rout] = rout = set_rout(request, env)
      env[:mega_page] = page_info = set_page_info(rout, rout_terms)
      env[:mega_pagination] = set_pagination_info(env, rout_terms)
      
      log_debug_info(env)
      page_info
    end

    def log_debug_info(env)
      puts "-----------------------------"
      puts "mega_rout: " + env[:mega_rout].inspect
      puts "mega_page: " + env[:mega_page].inspect
      puts "-----------------------------"
    end

    def handle_non_megabar_page(request, env)
      gotta_be_an_array = []
      rout = env[:mega_rout]
      
      if rout[:controller].nil?
        rout[:controller] = "flats"
        rout[:action] = "index"
      end

      @status, @headers, @page = (rout[:controller].classify.pluralize + "Controller").constantize.action(rout[:action]).call(env)
      gotta_be_an_array << (page = @page.blank? ? "" : @page.body.html_safe)
      [@status, @headers, gotta_be_an_array]
    end

    def set_rout(request, env)
      request_path_info = request.path_info.dup
      rout = (Rails.application.routes.recognize_path request_path_info, method: env["REQUEST_METHOD"] rescue {}) || {}
      rout = (MegaBar::Engine.routes.recognize_path request_path_info rescue {}) || {} if rout.empty? && request_path_info == "/mega-bar"
      rout = (MegaBar::Engine.routes.recognize_path request_path_info.sub!("/mega-bar/", ""), method: env["REQUEST_METHOD"] rescue {}) || {} if rout.empty?
      rout
    end

    def set_page_info(rout, rout_terms)
      page_info = {}
      rout_terms ||= []
      @prev_diff = Float::INFINITY
      
      MegaBar::Page.all.order(id: :desc).pluck(:id, :path, :name, :administrator).each do |page|
        next unless page_matches_rout_terms?(page[1], rout_terms)
        
        page_terms = page[1].split("/").reject! { |c| (c.nil? || c.empty?) } || []
        variable_segments = extract_variable_segments(page_terms, rout_terms)
        
        current_diff = calculate_path_difference(rout_terms, page_terms)
        if current_diff < @prev_diff
          page_info = build_page_info(page, page_terms, variable_segments)
          @prev_diff = current_diff
        end
      end
      
      page_info
    end

    def page_matches_rout_terms?(page_path, rout_terms)
      page_path_terms = page_path.split("/").map { |m| m if m[0] != ":" } - ["", nil]
      return false if (rout_terms - page_path_terms).size != rout_terms.size - page_path_terms.size
      return false if (page_path_terms.empty? && !rout_terms.empty?)
      true
    end

    def extract_variable_segments(page_terms, rout_terms)
      segments = []
      page_terms.each_with_index do |term, index|
        segments << rout_terms[index] if term.starts_with?(":")
      end
      
      begin
        if rout_terms[page_terms.size] && Integer(rout_terms[page_terms.size])
          segments << rout_terms[page_terms.size]
        end
      rescue ArgumentError
        # Not a valid integer, skip it
      end
      
      segments
    end

    def calculate_path_difference(rout_terms, page_terms)
      (rout_terms - page_terms).size
    end

    def build_page_info(page, page_terms, variable_segments)
      {
        page_id: page[0],
        page_path: page[1],
        terms: page_terms,
        vars: variable_segments,
        name: page[2],
        administrator: page[3]
      }
    end

    def set_pagination_info(env, rout_terms)
      pagination_info = []
      pagination_info.concat(extract_pagination_from_rout_terms(rout_terms))
      pagination_info.concat(extract_pagination_from_query_string(env))
      pagination_info
    end

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