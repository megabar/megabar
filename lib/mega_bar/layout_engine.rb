require 'active_record'
require 'sqlite3'
require 'logger'

class LayoutEngine
  # honestly, this is a hugely important file, but there shouldn't be anything in this file that concerns regular developers or users.
  # Here we figure out which is the current page, then collect which blocks go on a layout and which layouts go on a page.
  # For each block, if it holds a model_display, we'll call the controller for that model.
  # treat your controllers and models like you would in a normal rails app.
  # this does set some environment variables that are then used in your controllers, but inspect them there.
  # if you've set up your page->layouts->blocks->model_displays->field_displays properly this should just work.
  # if you've created a page using the gui and its not working.. check it's path setting and check your routes file to see that they are looking right.
  def initialize(app, message = "Response Time")
    @app = app
    @message = message
  end

  def call(env)
    dup._call(env)
  end

  def _call(env)
    # so.. a lot does go on here... I'll have to write a white paper.
    if env['PATH_INFO'].end_with?('.css')  || env['PATH_INFO'].end_with?('.js') || env['PATH_INFO'].end_with?('.jpeg')
      @status, @headers, @response = @app.call(env)
      return  [@status, @headers, self]
    end
    env['REQUEST_METHOD'] = "PATCH" if  env['REQUEST_METHOD'] == "PUT"
    @redirect = false
    request = Rack::Request.new(env)
    request.params # strangely this needs to be here for best_in_place updates.
    # MegaBar::Engine.routes.routes.named_routes.values.map do |route|
    site = MegaBar::Site.where(domains: request.host).first
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
    request.session[:return_to] = env['rack.request.query_hash']['return_to'] unless env['rack.request.query_hash']['return_to'].blank?
    rout_terms = request.path_info.split('/').reject! { |c| (c.nil? || c.empty?) }
    env[:mega_rout] = rout = set_rout(request, env) 
    env[:mega_page] = page_info = set_page_info(rout, rout_terms)
    pagination = set_pagination_info(env, rout_terms)
    if page_info.empty? #non megabar pages.
      gotta_be_an_array = []
      if rout[:controller].nil?
        rout[:controller] = 'flats'
        rout[:action] = 'index'
      end
      @status, @headers, @page = (rout[:controller].classify.pluralize + "Controller").constantize.action(rout[:action]).call(env)
      gotta_be_an_array << page = @page.blank? ? '' : @page.body.html_safe
      return @status, @headers, gotta_be_an_array
    end
    ################################
    orig_query_hash = Rack::Utils.parse_nested_query(env['QUERY_STRING'])
    final_layouts = []

    page_layouts = MegaBar::Layout.by_page(page_info[:page_id]).includes(:sites, :themes)

    page_layouts.each do | page_layout |
      next if mega_filtered(page_layout, site)
      env[:mega_layout] = page_layout
      blocks = MegaBar::Block.by_layout(page_layout.id).by_actions(rout[:action])
      final_blocks = []
      blocks.each do |blck|
        next if mega_filtered(blck, site)
        final_blocks << process_block(blck, page_info, rout, orig_query_hash, pagination, env)
      end
      env['mega_final_blocks'] = final_blocks #used in master_layouts_controller
      @status, @headers, @layouts = MegaBar::MasterLayoutsController.action(:render_layout_with_blocks).call(env)
      final_layouts <<  l = @layouts.blank? ? '' : @layouts.body.html_safe
    end
    env['mega_final_layouts'] = final_layouts
    @status, @headers, @page = MegaBar::MasterPagesController.action(:render_page).call(env)
    final_page = []
    final_page_content = @page.blank? ? '' : @page.body.html_safe
    # final_page_content = @page.instance_variable_get(:@response).nil? ? @page.instance_variable_get(:@body).instance_variable_get(:@stream).instance_variable_get(:@buf)[0] : @page.instance_variable_get(:@response).instance_variable_get(:@stream).instance_variable_get(:@buf)[0]
    final_page << final_page_content
    return @redirect ? [@redirect[0], @redirect[1], ['you are being redirected']] : [@status, @headers, final_page]
  end

  def each(&display)
    display.call("<!-- #{@message}: #{@stop - @start} -->\n") if (!@headers['Content-Type'].nil? && @headers["Content-Type"].include?("text/html"))
    @response.each(&display)
  end

  def set_page_info(rout, rout_terms)

    page_info = {}
    rout_terms ||= []
    diff = 20
    prev_diff = 21
    MegaBar::Page.all.order(' id desc').pluck(:id, :path, :name).each do | page |
      page_path_terms = page[1].split('/').map{ | m | m if m[0] != ':'} - ["", nil]
      next if (rout_terms - page_path_terms).size != rout_terms.size - page_path_terms.size
      next if (page_path_terms.empty? && !rout_terms.empty? ) # home page /
      diff = (rout_terms - page_path_terms).size
      page_terms = page[1].split('/').reject! { |c| (c.nil? || c.empty?) }
      page_terms ||= []
      variable_segments = []
      page_terms.each_with_index do | v, k |
        variable_segments << rout_terms[k] if page_terms[k].starts_with?(':')
      end
      variable_segments << rout_terms[page_terms.size] if Integer(rout_terms[page_terms.size]) rescue false
      page_info = {page_id: page[0], page_path: page[1], terms: page_terms, vars: variable_segments, name: page[2]} if diff < prev_diff
      prev_diff = diff
    end
    page_info
  end

  def set_rout(request, env)
    request_path_info = request.path_info.dup
    rout = (Rails.application.routes.recognize_path request_path_info, method: env['REQUEST_METHOD'] rescue {}) || {} 
    rout = (MegaBar::Engine.routes.recognize_path request_path_info rescue {}) || {}  if rout.empty? && request_path_info == '/mega-bar' #yeah, a special case for this one.
    rout = (MegaBar::Engine.routes.recognize_path request_path_info.sub!('/mega-bar/', ''), method: env['REQUEST_METHOD'] rescue {}) || {}  if rout.empty?
    rout
  end

  def set_pagination_info(env, rout_terms)
    rout_terms ||= []
    pagination_info = []
    rout_terms.map.with_index do |x, i|
     pagination_info <<  {kontrlr: x, page: rout_terms[i + 1] }  if /_page/ =~ x
    end
    q_hash = Rack::Utils.parse_nested_query(env['QUERY_STRING'])
    q_hash.keys.map do | key |
     pagination_info <<  {kontrlr: key, page: q_hash[key] }  if /_page/ =~ key
    end
    pagination_info
  end

  def process_block(blck, page_info, rout, orig_query_hash, pagination, env)
    if ! blck.html.nil? && ! blck.html.empty?
      blck.html.html_safe
    else
      params_hash = {} # used to set params var for controllers
      params_hash_arr = [] #used to collect 'params_hash' pieces
      mega_env = MegaEnv.new(blck, rout, page_info, pagination) # added to env for use in controllers
      params_hash_arr = mega_env.params_hash_arr
      env[:mega_env] = mega_env.to_hash
      params_hash_arr << {action: mega_env.block_action}
      params_hash_arr << {controller: mega_env.kontroller_path}
      params_hash_arr.each do |param|
        params_hash = params_hash.merge(param)
      end
      params_hash = params_hash.merge(orig_query_hash)
      params_hash = params_hash.merge(env['rack.request.form_hash']) if !env['rack.request.form_hash'].nil? # && (mega_env.block_action == 'update' || mega_env.block_action == 'create') 
      env['QUERY_STRING'] = params_hash.to_param # 150221!
      env['action_dispatch.request.parameters'] = params_hash

      @status, @headers, @disp_body = mega_env.kontroller_klass.constantize.action(mega_env.block_action).call(env)
      @redirect = [@status, @headers, @disp_body] if @status == 302
      block_body = @disp_body.blank? ? '' : @disp_body.body.html_safe
    end
  end

  def action_from_path(path, method, path_segments)
    path_array = path.split('/')
    if method == 'GET'
      if ['edit', 'new'].include?(path_array.last)
        path_array.last
      elsif path.last.match(/^(\d)+$/)
        'show'
      elsif  path_segments.include?(path_array.last)
        'index'
      else
        path_array.last
      end
    elsif ['POST', 'PUT', 'PATCH'].include? method
      path.last.match(/^(\d)+$/) ? 'update' : 'create'
    elsif ['DELETE'].include? method
      'delete'
    end
  end
 
  def mega_filtered(obj, site)
    if obj.sites
      has_zero_site = obj.sites.pluck(:id).include?(0)
      has_site = obj.sites.pluck(:id).include?(site.id)
      return true if has_zero_site and has_site
      return  true if !has_site
    end
    if obj.themes
      has_zero_theme = obj.themes.pluck(:id).include?(0)
      has_theme = obj.themes.pluck(:id).include?(site.theme_id)
      return true if has_zero_theme and has_theme
      return true if !has_theme
    end
    false
  end
end


class MegaEnv
  attr_writer :mega_model_properties, :mega_displays, :nested_ids
  attr_reader :block, :modle, :modle_id, :mega_model_properties, :klass, :kontroller_inst, :kontroller_path, :kontroller_klass, :mega_displays, :nested_ids, :block_action, :params_hash_arr, :nested_class_info

  def initialize(blck, rout, page_info, pagination)
    @block_model_displays =   MegaBar::ModelDisplay.by_block(blck.id)
    @displays = blck.actions == 'current' ? @block_model_displays.by_block(blck.id).by_action(rout[:action]) : @block_model_displays.by_block(blck.id)
    @block_action = @displays.empty? ? rout[:action] : @displays.first.action
    @modle = MegaBar::Model.by_model(@block_model_displays.first.model_id).first
    @modle_id = @modle.id
    @modyule = @modle.modyule.empty? ? '' : @modle.modyule + '::'
    @kontroller_klass = @modyule + @modle.classname.classify.pluralize + "Controller"
    @kontroller_path = @modle.modyule.nil? || @modle.modyule.empty? ?   @modle.classname.pluralize.underscore :  @modyule.split('::').map { | m | m = m.underscore }.join('/') + '/' + @modle.classname.pluralize.underscore
    @klass = (@modyule + @modle.classname.classify).constantize
    meta_programming(@klass, @modle)
    @kontroller_inst = @modle.classname.underscore
    @mega_displays = set_mega_displays(@displays)
    @nested_ids, @params_hash_arr, @nested_classes = nest_info(blck, rout, page_info)
    @nested_class_info = set_nested_class_info(@nested_classes)
    @block = blck
    @page_number = pagination.map {|info| info[:page].to_i if info[:kontrlr] == @kontroller_inst + '_page' }.compact.first
  end

  def to_hash
    {
      block: @block,
      modle_id: @modle_id,
      mega_model_properties: @modle,
      klass: @klass,
      kontroller_inst: @kontroller_inst,
      kontroller_path: @kontroller_path,
      mega_displays: @mega_displays,
      nested_ids: @nested_ids,
      nested_class_info: @nested_class_info,
      page_number: @page_number
    }
  end

  def meta_programming(klass, modle) 
    position_parent_method = modle.position_parent.split("::").last.underscore.downcase.to_sym unless modle.position_parent.blank?
    klass.class_eval{ acts_as_list scope: position_parent_method, add_new_at: :bottom } if position_parent_method
  end
  def set_mega_displays(displays)
    mega_displays_info = [] # collects model and field display settings
    displays.each do | display |
      model_display_format = MegaBar::ModelDisplayFormat.find(display.format)
      model_display_collection_settings = MegaBar::ModelDisplayCollection.by_model_display_id(display.id).first if display.collection_or_member == 'collection'
      field_displays = MegaBar::FieldDisplay.by_model_display_id(display.id).order('position asc')
      displayable_fields = []
      field_displays.each do |field_disp|
        field = MegaBar::Field.find(field_disp.field_id)
        if is_displayable?(field_disp.format)
          #lets figure out how to display it right here.
          puts field_disp.format 
          data_format = Object.const_get('MegaBar::' + field_disp.format.classify).by_field_display_id(field_disp.id).last #data_display models have to have this scope!
          if field_disp.format == 'select'
            options = MegaBar::Option.where(field_id: field.id).collect {|o| [ o.text, o.value ] }
          end
          displayable_fields << {field_display: field_disp, field: field, data_format: data_format, options: options, obj: @mega_instance}
        end
      end
      info = {
        :model_display_format => model_display_format, # Object.const_get('MegaBar::' + MegaBar::RecordsFormat.find(md.format).name).new,
        :displayable_fields => displayable_fields,
        :model_display => display,
        :collection_settings => model_display_collection_settings
      }
      mega_displays_info << info
    end
    mega_displays_info
  end

  def nest_info(blck, rout, page_info)
    params_hash_arr = []
    nested_ids = []
    nested_classes = []
    puts "================="
    puts blck, rout, page_info

    if blck.path_base
      if page_info[:page_path].starts_with?(blck.path_base) || blck.path_base.starts_with?(page_info[:page_path])
        block_path_vars = blck.path_base.split('/').map{ | m | m if m[0] == ':'} - ["", nil]
        depth = 0
        puts 'bpv' + block_path_vars.to_s
        until depth == block_path_vars.size + 1
          # puts MegaBar::Model.find(blck.send("nest_level_#{depth}"))
          blck_model = depth == 0 ? modle :  MegaBar::Model.find(blck.send("nest_level_#{depth}"))
          fk_field =  depth == 0 ? 'id' : blck_model.classname.underscore.downcase +  '_id'
          new_hash = {fk_field => page_info[:vars][block_path_vars.size - depth]}
          params_hash_arr <<  new_hash
          nested_ids << new_hash if depth > 0
          nested_classes << blck_model
          depth += 1
        end
      end
    else
      # you can do layouts with a block nested one deep without setting path_base
      params_hash_arr << h =(rout[:id] && blck.nest_level_1.nil?) ? {id: rout[:id]} : {id: nil}
      params_hash_arr << i =  {MegaBar::Model.find(blck.nest_level_1).classname.underscore + '_id' =>  rout[:id]} if !blck.nest_level_1.nil?
      nested_ids << i if i
    end
    return nested_ids, params_hash_arr, nested_classes
  end
  def set_nested_class_info(nested_classes)
    nested_class_info = []
    nested_classes.each_with_index do |nc, idx|
      modyule = nc.modyule.empty? ? '' : nc.modyule + '::'
      klass = modyule + nc.classname.classify
      nested_class_info << [klass, nc.classname.underscore] if idx != 0
    end
    nested_class_info
  end
  def is_displayable?(format)
    return  (format == 'hidden' || format == 'off') ? false : true
  end
end

class FlatsController < ActionController::Base
  def index
  end
end
