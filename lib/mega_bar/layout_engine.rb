require "active_record"
# require 'sqlite3'
require "logger"
require_relative 'mega_env'
require_relative 'block_filter'
require_relative 'page_info_processor'
require_relative 'pagination_processor'

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
    return handle_static_assets(env) if static_asset?(env)
    
    setup_request_environment(env)
    return handle_non_megabar_page(env) if env[:mega_page].empty?
    
    render_megabar_page(env)
  end

  def each(&display)
    display.call("<!-- #{@message}: #{@stop - @start} -->\n") if (!@headers["Content-Type"].nil? && @headers["Content-Type"].include?("text/html"))
    @response.each(&display)
  end


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
      MegaBar::PageInfoProcessor.new(rout, rout_terms).process
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

  module PageProcessing
    def render_megabar_page(env)
      orig_query_hash = Rack::Utils.parse_nested_query(env["QUERY_STRING"])
      final_layouts = process_layouts(env, orig_query_hash)
      
      env["mega_final_layouts"] = final_layouts
      @status, @headers, @page = MegaBar::MasterPagesController.action(:render_page).call(env)
      
      final_page_content = @page.blank? ? "" : @page.body.html_safe
      final_page = [final_page_content]
      
      @redirect ? [@redirect[0], @redirect[1], ["you are being redirected"]] : [@status, @headers, final_page]
    end

    def process_layouts(env, orig_query_hash)
      page_layouts = MegaBar::Layout.by_page(env[:mega_page][:page_id]).includes(:sites, :themes)
      final_layouts = []
      
      page_layouts.each do |page_layout|
        next if mega_filtered(page_layout, env[:mega_site])
        
        env[:mega_layout] = page_layout
        final_layout_sections = process_page_layout(page_layout, env[:mega_page], env[:mega_rout], orig_query_hash, env[:mega_pagination], env[:mega_site], env)
        
        env["mega_final_layout_sections"] = final_layout_sections
        @status, @headers, @layouts = MegaBar::MasterLayoutsController.action(:render_layout_with_sections).call(env)
        final_layouts << (@layouts.blank? ? "" : @layouts.body.html_safe)
      end
      
      final_layouts
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
  end

  module BlockProcessing
    def get_filtered_blocks(layout_section, rout, page_info)
      MegaBar::BlockFilter.new(layout_section, rout, page_info).filter
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

  include RequestProcessing
  include PageProcessing
  include BlockProcessing

end

class FlatsController < ActionController::Base
  def index
  end

  def app
    redirect_to "/app"
  end
end
