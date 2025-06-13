require_relative 'mega_env'

class RequestProcessor
  def initialize(app = nil)
    @app = app
  end

  def process(env)
    return handle_static_assets(env) if static_asset?(env)
    
    setup_request_environment(env)
    return handle_non_megabar_page(env) if env[:mega_page].empty?
    
    env
  end

  private

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
    setup_user(request, env)
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

  def setup_user(request, env)
    @user = env[:mega_user] = if request.session["user_id"] && MegaBar::User.all.size > 0
      MegaBar::User.find(request.session["user_id"])
    else
      MegaBar::User.new
    end
  end

  def handle_non_megabar_page(env)
    rout = env[:mega_rout]
    rout[:controller] ||= "flats"
    rout[:action] ||= "index"
    
    @status, @headers, @page = (rout[:controller].classify.pluralize + "Controller").constantize.action(rout[:action]).call(env)
    page_content = @page.blank? ? "" : @page.body.html_safe
    [@status, @headers, [page_content]]
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

  def set_pagination_info(env, rout_terms)
    pagination_info = []
    pagination_info.concat(extract_pagination_from_rout_terms(rout_terms))
    pagination_info.concat(extract_pagination_from_query_string(env))
    pagination_info
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