module MegaBar
  class RouteResolver
    def initialize(request, env)
      @request = request
      @env = env
    end

    def resolve
      request_path_info = @request.path_info.dup
      
      # EXACT master branch logic - try Rails routes first
      rails_route = recognize_rails_route(request_path_info)
      
      # If Rails route found, return it immediately (this handles MegaRoute.load dynamic routes)
      unless rails_route.empty?
        # Temporary debug for /mega-bar/selects
        if request_path_info.include?("selects")
          Rails.logger.info "🚀 RouteResolver: Found Rails route for #{request_path_info}: #{rails_route.inspect}"
        end
        # Debug for root path
        if request_path_info == "/"
          Rails.logger.info "🏠 RouteResolver: Found Rails route for ROOT: #{rails_route.inspect}"
        end
        return rails_route
      end
      
      # Rails route empty - try MegaBar routes as fallback
      megabar_route = recognize_megabar_route(request_path_info)
      
      # Temporary debug for /mega-bar/selects
      if request_path_info.include?("selects")
        Rails.logger.info "🚀 RouteResolver: Rails empty, MegaBar route for #{request_path_info}: #{megabar_route.inspect}"
      end
      # Debug for root path
      if request_path_info == "/"
        Rails.logger.info "🏠 RouteResolver: Rails empty, MegaBar route for ROOT: #{megabar_route.inspect}"
      end
      
      megabar_route
    end

    private

    def recognize_rails_route(path_info)
      Rails.application.routes.recognize_path(path_info, method: @env["REQUEST_METHOD"])
    rescue ActionController::RoutingError
      {}
    end

    def recognize_megabar_route(path_info)
      # Special case for /mega-bar root path
      if path_info == "/mega-bar"
        begin
          return MegaBar::Engine.routes.recognize_path(path_info)
        rescue ActionController::RoutingError
          # Continue to try prefixed path
        end
      end
      
      # Try with /mega-bar/ prefix removed
      if path_info.start_with?("/mega-bar/")
        cleaned_path = path_info.sub("/mega-bar/", "")
        begin
          MegaBar::Engine.routes.recognize_path(cleaned_path, method: @env["REQUEST_METHOD"])
        rescue ActionController::RoutingError
          {}
        end
      else
        {}
      end
    end
  end

  class PageResolver
    def initialize(route_info, path_info)
      @route_info = route_info
      @route_terms = extract_route_terms(path_info)
    end

    def resolve
      
      # Don't return early for empty route_terms - home page should be matched!
      
      # Use efficient query instead of loading all pages
      candidate_pages = find_candidate_pages
      result = find_best_matching_page(candidate_pages)
      
      # Ensure we always return a hash with expected keys to prevent nil errors
      if result.empty?
        {
          page_id: nil,
          page_path: "/",
          terms: [],
          vars: [],
          name: "Home",
          administrator: 0
        }
      else
        result
      end
    end

    private

    def extract_route_terms(path_info)
      path_info.split("/").reject { |c| c.nil? || c.empty? }
    end

    def find_candidate_pages
      # byebug - removed excessive debugging
      
      candidates = if @route_terms.blank?
        # For home page (empty route terms), find pages with empty or root paths
        MegaBar::Page.where("path = '/' OR path = '' OR path IS NULL").limit(20).pluck(:id, :path, :name, :administrator)
      else
        # More efficient than loading all pages
        MegaBar::Page.where(
          "path LIKE ? OR path LIKE ?",
          "/#{@route_terms.join('/')}%",
          "/#{@route_terms.first}%"
        ).limit(20).pluck(:id, :path, :name, :administrator)
      end
      
      # Debug: let's see what candidates we found and check for page_id 15
      
      # Check if page_id 15 exists and what its path is
      page_15 = MegaBar::Page.find_by(id: 15)
      
      candidates
    end

    def find_best_matching_page(candidates)
      # byebug - removed excessive debugging
      best_match = nil
      best_score = Float::INFINITY

      candidates.each do |page_data|
        page_id, page_path, page_name, administrator = page_data
        page_path_terms = extract_path_terms(page_path)
        
        next unless compatible_path?(@route_terms, page_path_terms)
        # Remove the problematic home_page_mismatch check - let's debug this separately
        # next if home_page_mismatch?(page_path_terms, @route_terms)
        
        score = calculate_path_difference(@route_terms, page_path_terms)
        
        if score < best_score
          best_score = score
          # Load the actual page object and build proper page_info
          page = MegaBar::Page.find_by(id: page_id)
          best_match = build_page_info(page, page_path)
        end
      end

      best_match || {}
    end

    def extract_path_terms(path)
      path.split("/").map { |m| m if m[0] != ":" } - ["", nil]
    end

    def compatible_path?(route_terms, page_path_terms)
      # Special case: both empty means home page match
      return true if route_terms.empty? && page_path_terms.empty?
      
      # Original logic for non-empty paths
      (route_terms - page_path_terms).size == route_terms.size - page_path_terms.size
    end

    def calculate_path_difference(route_terms, page_path_terms)
      # Home page match has perfect score
      return 0 if route_terms.empty? && page_path_terms.empty?
      
      (route_terms - page_path_terms).size
    end

    def build_page_info(page, page_path = nil)
      if page.nil?
        return {
          page_id: nil,
          page_path: page_path || "/",
          terms: [],
          vars: [],
          name: "Home",
          administrator: 0
        }
      end

      # Extract variable segments from the page path  
      page_terms = page_path ? page_path.split('/').reject(&:blank?) : []
      variable_segments = extract_variable_segments(page_terms)

      {
        page_id: page.id,
        page_path: page_path || page.path || "/",  # Multiple fallbacks to ensure never nil
        terms: page_terms || [],
        vars: variable_segments || [],
        name: page.name || "Home",
        administrator: page.administrator || 0
      }
    end

    def extract_variable_segments(page_terms)
      variable_segments = []
      
      page_terms.each_with_index do |term, index|
        if term.starts_with?(":")
          variable_segments << @route_terms[index]
        end
      end
      
      # Handle trailing numeric segment
      trailing_segment = @route_terms[page_terms.size]
      if trailing_segment && numeric?(trailing_segment)
        variable_segments << trailing_segment
      end
      
      variable_segments
    end

    def numeric?(string)
      Integer(string)
      true
    rescue ArgumentError
      false
    end
  end

  class PaginationResolver
    def initialize(env, route_terms)
      @env = env
      @route_terms = route_terms || []
    end

    def resolve
      pagination_info = []
      
      # Extract pagination from path segments
      @route_terms.each_with_index do |term, index|
        if term.match(/_page$/)
          pagination_info << { kontrlr: term, page: @route_terms[index + 1] }
        end
      end
      
      # Extract pagination from query parameters
      query_hash = Rack::Utils.parse_nested_query(@env["QUERY_STRING"])
      query_hash.each do |key, value|
        if key.match(/_page$/)
          pagination_info << { kontrlr: key, page: value }
        end
      end
      
      pagination_info
    end
  end

  class ActionResolver
    def initialize(path, method, path_segments)
      @path = path
      @method = method
      @path_segments = path_segments || []
    end

    def resolve
      case @method
      when LayoutEngine::HTTP_GET
        resolve_get_action
      when *LayoutEngine::MODIFICATION_METHODS
        resolve_modification_action
      when *LayoutEngine::DELETION_METHODS
        "delete"
      else
        "index"
      end
    end

    private

    def resolve_get_action
      path_array = @path.split("/")
      last_segment = path_array.last
      
      return last_segment if %w[edit new].include?(last_segment)
      return "show" if numeric?(last_segment)
      return "index" if @path_segments.include?(last_segment)
      
      last_segment
    end

    def resolve_modification_action
      path_array = @path.split("/")
      numeric?(path_array.last) ? "update" : "create"
    end

    def numeric?(string)
      string.match(/^\d+$/)
    end
  end
end 