require "active_record"
# require 'sqlite3'
require "logger"
require_relative 'mega_env'
require_relative 'block_filter'
require_relative 'page_info_processor'
require_relative 'pagination_processor'
require_relative 'request_processing'
require_relative 'page_processing'
require_relative 'block_processing'

module MegaBar
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
    puts "🔍 DEBUG: _call - PATH_INFO: #{env['PATH_INFO']}, METHOD: #{env['REQUEST_METHOD']}"
    
    return handle_static_assets(env) if static_asset?(env)
    
    # Check if this is a Devise route early and pass it through immediately
    path_info = env['PATH_INFO']
    if is_devise_route?(path_info)
      puts "🔍 DEBUG: Early Devise route detection: #{path_info}"
      puts "🔍 DEBUG: Passing through to host application immediately"
      return @app.call(env)
    end
    
    # Ensure Warden is set up before processing
    setup_warden(env)
    
    setup_request_environment(env)
    puts "🔍 DEBUG: _call - mega_page: #{env[:mega_page].inspect}"
    
    return handle_non_megabar_page(env) if env[:mega_page].empty?
    render_megabar_page(env)
  end

  def setup_warden(env)
    # Ensure Warden proxy is available
    unless env['warden']
      puts "🔍 DEBUG: Setting up Warden proxy"
      # Create a minimal Warden proxy for Devise helpers
      env['warden'] = Warden::Proxy.new(env, Warden::Manager.new(nil))
    end
  end


  def each(&display)
    display.call("<!-- #{@message}: #{@stop - @start} -->\n") if (!@headers["Content-Type"].nil? && @headers["Content-Type"].include?("text/html"))
    @response.each(&display)
  end








  include RequestProcessing
  include PageProcessing
  include BlockProcessing

  def is_devise_route?(path_info)
    # Check for common Devise route patterns
    devise_patterns = [
      /^\/users\/sign_in$/,
      /^\/users\/sign_up$/,
      /^\/users\/sign_out$/,
      /^\/users\/password\/new$/,
      /^\/users\/password$/,
      /^\/users\/password\/edit$/,
      /^\/users\/confirmation$/,
      /^\/users\/confirmation\/new$/,
      /^\/users\/unlock\/new$/,
      /^\/users\/unlock$/,
      /^\/users\/edit$/,
      /^\/users\/cancel$/,
      /^\/users\/sign_up\/.*$/,  # For custom registration paths
      /^\/users\/sign_in\/.*$/   # For custom session paths
    ]
    
    devise_patterns.any? { |pattern| path_info.match?(pattern) }
  end

end

end

class FlatsController < ActionController::Base
  def index
  end

  def app
    redirect_to "/app"
  end
end
