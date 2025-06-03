require "active_record"
# require 'sqlite3'
require "logger"
require_relative 'mega_env'
require_relative 'request_processor'
require_relative 'page_processor'

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
    @request_processor = MegaBar::RequestProcessor.new(app)
    @page_processor = MegaBar::PageProcessor.new(app)
  end

  def call(env)
    dup._call(env)
  end

  def _call(env)
    env, page_info = @request_processor.process(env)
    return env if env.is_a?(Array) # Handle non-megabar pages or static assets

    @page_processor.process(env, page_info)
  end

  def each(&display)
    display.call("<!-- #{@message}: #{@stop - @start} -->\n") if (!@headers["Content-Type"].nil? && @headers["Content-Type"].include?("text/html"))
    @response.each(&display)
  end
end

class FlatsController < ActionController::Base
  def index
  end

  def app
    redirect_to "/app"
  end
end
