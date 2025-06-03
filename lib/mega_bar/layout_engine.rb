require "active_record"
# require 'sqlite3'
require "logger"
require_relative 'mega_env'

class LayoutEngine
  # honestly, this is a hugely important file, but there shouldn't be anything in this file that concerns regular developers or users.
  # Here we figure out which is the current page, then collect which blocks go on a layout and which layouts go on a page.
  # For each block, if it holds a model_display, we'll call the controller for that model.
  # treat your controllers and models like you would in a normal rails app.
  # this does set some environment variables that are then used in your controllers, but inspect them there.
  # if you've set up your page->layouts->blocks->model_displays->field_displays properly this should just work.
  # if you've created a page using the gui and its not working.. check it's path setting and check your routes file to see that they are looking right.
  def initialize(app = nil, message = "Response Time")
    @app = app
    @message = message
  end

  def call(env)
    dup._call(env)
  end

  def _call(env)

    # so.. a lot does go on here... I'll have to write a white paper.
    if env["PATH_INFO"].end_with?(".sass") || env["PATH_INFO"].end_with?(".css") || env["PATH_INFO"].end_with?(".js") || env["PATH_INFO"].end_with?(".jpeg") || env["PATH_INFO"].end_with?(".jpg")
      @status, @headers, @response = @app.call(env)
      return [@status, @headers, self]
    end
    if env["PATH_INFO"].end_with?(".json")
      @status, @headers, @response = @app.call(env)
      return [@status, @headers, self]
    end
    env["REQUEST_METHOD"] = "PATCH" if env["REQUEST_METHOD"] == "PUT"
    @redirect = false
    request = Rack::Request.new(env)
    request.params # strangely this needs to be here for best_in_place updates.
    # MegaBar::Engine.routes.routes.named_routes.values.map do |route|
    site = MegaBar::Site.where(domains: request.host).first
    site.present? ? site : MegaBar::Site.where(domains: "base").first
    env[:mega_site] = site
    #   puts  route.instance_variable_get(:@constraints)[:request_method].to_s + "#{route.defaults[:controller]}##{route.defaults[:action]}"
    # end #vs. Rails.application.routes.routes.named_routes.values.map
    # Rails.application.routes.routes.named_routes.values.map do |route|
    #   puts  route.instance_variable_get(:@constraints)[:request_method].to_s + "#{route.defaults[:controller]}##{route.defaults[:action]}"
    # end #vs. Rails.application.routes.routes.named_routes.values.map
    ################################
    ## figure out what page it is
    # the general strategy is..
    # have rails recognize the path_info..
    # tbcontinued.
    request.session[:return_to] = env["rack.request.query_hash"]["return_to"] unless env["rack.request.query_hash"]["return_to"].blank?
    request.session[:return_to] = nil if env["rack.request.query_hash"]["method"].present?
    rout_terms = request.path_info.split("/").reject! { |c| (c.nil? || c.empty?) }
    env[:mega_rout] = rout = set_rout(request, env)
    env[:mega_page] = page_info = set_page_info(rout, rout_terms)
    pagination = set_pagination_info(env, rout_terms)
    puts "-----------------------------"
    puts "mega_rout: " + env[:mega_rout].inspect
    puts "mega_page: " + env[:mega_page].inspect
    puts "-----------------------------"
    # request.env["devise.mapping"] = Devise.mappings[:user]
    # request.env['warden'] = Warden::Proxy.new({}, Warden::Manager.new({})).tap{|i| i.set_user({user: 7}, scope: {user: 7}) }
    request.session[:init] = true #unless request.session
    request.session[:admin_pages] ||= []
    @user = env[:mega_user] = request.session["user_id"] && MegaBar::User.all.size > 0 ? MegaBar::User.find(request.session["user_id"]) : MegaBar::User.new
    if page_info.empty? #non megabar pages.
      puts "NON MEGABAR PAGE"
      gotta_be_an_array = []
      if rout[:controller].nil?
        rout[:controller] = "flats"
        rout[:action] = "index"
      end
      # request.session["warden.user.user.key"] = nil if ( rout[:controller] == 'sessions' && rout[:action] == 'destroy')
      @status, @headers, @page = (rout[:controller].classify.pluralize + "Controller").constantize.action(rout[:action]).call(env)
      gotta_be_an_array << page = @page.blank? ? "" : @page.body.html_safe
      return @status, @headers, gotta_be_an_array
    end
    ################################
    orig_query_hash = Rack::Utils.parse_nested_query(env["QUERY_STRING"])
    final_layouts = []

    page_layouts = MegaBar::Layout.by_page(page_info[:page_id]).includes(:sites, :themes)

    page_layouts.each do |page_layout|
      next if mega_filtered(page_layout, site)
      env[:mega_layout] = page_layout
      final_layout_sections = process_page_layout(page_layout, page_info, rout, orig_query_hash, pagination, site, env)

      env["mega_final_layout_sections"] = final_layout_sections #used in master_layouts_controller
      @status, @headers, @layouts = MegaBar::MasterLayoutsController.action(:render_layout_with_sections).call(env)
      final_layouts << l = @layouts.blank? ? "" : @layouts.body.html_safe
    end

    env["mega_final_layouts"] = final_layouts
    @status, @headers, @page = MegaBar::MasterPagesController.action(:render_page).call(env)
    final_page = []
    final_page_content = @page.blank? ? "" : @page.body.html_safe
    # final_page_content = @page.instance_variable_get(:@response).nil? ? @page.instance_variable_get(:@body).instance_variable_get(:@stream).instance_variable_get(:@buf)[0] : @page.instance_variable_get(:@response).instance_variable_get(:@stream).instance_variable_get(:@buf)[0]
    final_page << final_page_content
    return @redirect ? [@redirect[0], @redirect[1], ["you are being redirected"]] : [@status, @headers, final_page]
  end

  def each(&display)
    display.call("<!-- #{@message}: #{@stop - @start} -->\n") if (!@headers["Content-Type"].nil? && @headers["Content-Type"].include?("text/html"))
    @response.each(&display)
  end

  def set_page_info(rout, rout_terms)
    page_info = {}
    rout_terms ||= []
    @prev_diff = Float::INFINITY  # Initialize with infinity to ensure first match is accepted
    
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

  private

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
    
    # Add numeric segment if present
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

  def set_rout(request, env)
    request_path_info = request.path_info.dup
    rout = (Rails.application.routes.recognize_path request_path_info, method: env["REQUEST_METHOD"] rescue {}) || {}
    rout = (MegaBar::Engine.routes.recognize_path request_path_info rescue {}) || {} if rout.empty? && request_path_info == "/mega-bar" #yeah, a special case for this one.
    rout = (MegaBar::Engine.routes.recognize_path request_path_info.sub!("/mega-bar/", ""), method: env["REQUEST_METHOD"] rescue {}) || {} if rout.empty?
    rout
  end

  def set_pagination_info(env, rout_terms)
    pagination_info = []
    pagination_info.concat(extract_pagination_from_rout_terms(rout_terms))
    pagination_info.concat(extract_pagination_from_query_string(env))
    pagination_info
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

  def process_page_layout(page_layout, page_info, rout, orig_query_hash, pagination, site, env)
    final_layout_sections = {}
    
    page_layout.layout_sections.each do |layout_section|
      process_layout_section(layout_section, page_layout, page_info, rout, orig_query_hash, pagination, site, env, final_layout_sections)
    end
    
    final_layout_sections
  end

  def process_layout_section(layout_section, page_layout, page_info, rout, orig_query_hash, pagination, site, env, final_layout_sections)
    template_section = get_template_section(layout_section, page_layout)
    blocks = get_filtered_blocks(layout_section, rout, page_info)
    return unless blocks.present?

    final_layout_sections[template_section] = []
    env[:mega_layout_section] = layout_section
    
    process_blocks(blocks, page_info, rout, orig_query_hash, pagination, site, env, final_layout_sections, template_section)
  end

  def get_template_section(layout_section, page_layout)
    MegaBar::TemplateSection.find(
      layout_section.layables.where(layout_id: page_layout.id).first.template_section_id
    ).code_name
  end

  def get_filtered_blocks(layout_section, rout, page_info)
    blocks = MegaBar::Block.by_layout_section(layout_section.id).order(position: :asc)
    blocks = blocks.by_actions(rout[:action]) unless rout.blank?
    
    case layout_section.rules
    when "specific"
      filter_specific_blocks(blocks, page_info)
    when "chosen"
      filter_chosen_blocks(blocks, page_info)
    else
      blocks
    end
  end

  def filter_specific_blocks(blocks, page_info)
    rout_terms = page_info[:page_path].split("/").reject! { |c| (c.nil? || c.empty?) }
    best_block = find_best_matching_block(blocks, rout_terms)
    blocks.reject { |b| b.id != best_block.id }
  end

  def find_best_matching_block(blocks, rout_terms)
    diff = 20
    prev_diff = 21
    best = nil

    blocks.each do |block|
      page_path_terms = block.path_base.split("/").map { |m| m if m[0] != ":" } - ["", nil]
      next if (rout_terms - page_path_terms).size != rout_terms.size - page_path_terms.size
      next if (page_path_terms.empty? && !rout_terms.empty?)

      current_diff = (rout_terms - page_path_terms).size
      if current_diff < prev_diff
        best = block
        prev_diff = current_diff
      end
    end

    best
  end

  def filter_chosen_blocks(blocks, page_info)
    model = MegaBar::Model.where(classname: page_info[:terms][0].classify).first
    chosen_fields = model.fields.where("field LIKE ?", "%template%").pluck(:field)
    chosen_obj = page_info[:terms][0].classify.constantize.find(page_info[:vars][0].to_i)
    chosen_blocks = chosen_fields.map { |f| chosen_obj.send(f) }
    blocks.where(id: chosen_blocks)
  end

  def process_blocks(blocks, page_info, rout, orig_query_hash, pagination, site, env, final_layout_sections, template_section)
    final_blocks = blocks.map do |blck|
      next if mega_filtered(blck, site)
      build_block_info(blck, page_info, rout, orig_query_hash, pagination, env)
    end.compact

    env["mega_final_blocks"] = final_blocks
    render_layout_section(env, final_layout_sections, template_section)
  end

  def build_block_info(blck, page_info, rout, orig_query_hash, pagination, env)
    {
      id: blck.id,
      header: blck.model_displays.where(action: "index").first&.header,
      actions: blck.actions,
      action: rout[:action],
      html: process_block(blck, page_info, rout, orig_query_hash, pagination, env)
    }
  end

  def render_layout_section(env, final_layout_sections, template_section)
    @status, @headers, @layout_sections = MegaBar::MasterLayoutSectionsController
      .action(:render_layout_section_with_blocks)
      .call(env)
    
    final_layout_sections[template_section] << (
      @layout_sections.blank? ? "" : @layout_sections.body.html_safe
    )
  end

  def process_block(blck, page_info, rout, orig_query_hash, pagination, env)
    return render_html_block(blck) if has_html_content?(blck)
    return "" if blck.model_displays.empty?
    
    process_model_display_block(blck, page_info, rout, orig_query_hash, pagination, env)
  end

  private

  def has_html_content?(blck)
    blck.html.present? && !blck.html.empty?
  end

  def render_html_block(blck)
    blck.html.html_safe
  end

  def process_model_display_block(blck, page_info, rout, orig_query_hash, pagination, env)
    mega_env = MegaBar::MegaEnv.new(blck, rout, page_info, pagination, @user)
    setup_environment(mega_env, orig_query_hash, env)
    render_block_content(mega_env, blck, env)
  end

  def setup_environment(mega_env, orig_query_hash, env)
    params_hash = build_params_hash(mega_env, orig_query_hash, env)
    env[:mega_env] = mega_env.to_hash
    env["QUERY_STRING"] = params_hash.to_param
    env["action_dispatch.request.parameters"] = params_hash
    setup_block_classes(env, mega_env.block)
  end

  def build_params_hash(mega_env, orig_query_hash, env)
    params_hash = {}
    params_hash_arr = mega_env.params_hash_arr + [
      { action: mega_env.block_action },
      { controller: mega_env.kontroller_path }
    ]
    
    params_hash_arr.each { |param| params_hash.merge!(param) }
    params_hash.merge!(orig_query_hash)
    params_hash.merge!(env["rack.request.form_hash"]) if env["rack.request.form_hash"].present?
    
    params_hash
  end

  def setup_block_classes(env, blck)
    env["block_classes"] = [
      blck.name.downcase.parameterize.underscore,
      ("active" if first_tab(env, blck))
    ].compact
  end

  def render_block_content(mega_env, blck, env)
    @status, @headers, @disp_body = mega_env.kontroller_klass.constantize
      .action(mega_env.block_action)
      .call(env)
    
    @redirect = [@status, @headers, @disp_body] if @status == 302
    @disp_body.blank? ? "" : @disp_body.body.html_safe
  end

  def first_tab(env, blck)
    return false if env[:mega_layout_section]&.rules != "tabs"

    blck.id == MegaBar::Block.by_layout_section(blck.layout_section_id).where(actions: "show").first&.id
  end

  def action_from_path(path, method, path_segments)
    path_array = path.split("/")
    if method == "GET"
      if ["edit", "new"].include?(path_array.last)
        path_array.last
      elsif path.last.match(/^(\d)+$/)
        "show"
      elsif path_segments.include?(path_array.last)
        "index"
      else
        path_array.last
      end
    elsif ["POST", "PUT", "PATCH"].include? method
      path.last.match(/^(\d)+$/) ? "update" : "create"
    elsif ["DELETE"].include? method
      "delete"
    end
  end

  def mega_filtered(obj, site)
    if obj.sites.present?
      has_zero_site = obj.sites.pluck(:id).include?(0)
      has_site = obj.sites.pluck(:id).include?(site.id)
      return true if has_zero_site and has_site
      return true if !has_site
    end
    if obj.themes.present?
      has_zero_theme = obj.themes.pluck(:id).include?(0)
      has_theme = obj.themes.pluck(:id).include?(site.theme_id)
      return true if has_zero_theme and has_theme
      return true if !has_theme
    end
    false
  end
end

class FlatsController < ActionController::Base
  def index
  end

  def app
    redirect_to "/app"
  end
end
