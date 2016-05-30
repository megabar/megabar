ENV['RAILS_ENV'] ||= 'test'
MEGABAR_ROOT=File.join(File.dirname(__FILE__), '../../megabar/') #feel free to modify for your environment.
require 'bundler/setup'
require 'byebug'
require 'factory_girl_rails'
require 'rails/all'
require 'rake'
require 'rspec/rails'

require MEGABAR_ROOT + 'spec/controllers/common'

require File.expand_path("../../config/environment", __FILE__)

require 'rubygems'
load File.expand_path(MEGABAR_ROOT + "lib/tasks/mega_bar_tasks.rake", __FILE__)
include FactoryGirl::Syntax::Methods
Dir[File.join(MEGABAR_ROOT, "spec/internal/factories/*.rb")].each { |f| require f }
Rake::Task.define_task(:environment)

ActiveRecord::Migration.maintain_test_schema!

Rails.application.routes.draw do


 get '/mega-bar/models', to: 'flats#index'
 get '/mega-bar/fields', to: 'flats#index'
 get '/mega-bar/model_displays', to: 'flats#index'
 get '/mega-bar/field_displays', to: 'flats#index'
 get '/mega-bar/textboxes', to: 'flats#index'
 get '/mega-bar/textreads', to: 'flats#index'
 get '/mega-bar/selects', to: 'flats#index'
 get '/mega-bar/model-display-formats', to: 'flats#index'
 get '/mega-bar/options', to: 'flats#index'
 get '/mega-bar/pages', to: 'flats#index'
 get '/mega-bar/layouts', to: 'flats#index'
 get '/mega-bar/blocks', to: 'flats#index'
 get '/mega-bar/pages/:page_id/layouts', to: 'flats#index'
 get '/mega-bar/pages/:page_id/layouts/:layout_id/blocks', to: 'flats#index'
 get '/mega-bar/pages/:page_id/layouts/:layout_id/blocks/:block_id/model_displays', to: 'flats#index'
 get '/mega-bar/pages/:page_id/layouts/:layout_id/blocks/:block_id/model_displays/:model_display_id/field_displays', to: 'flats#index'
 get '/mega-bar/pages/:page_id/layouts/:layout_id/blocks/:block_id/displays/:model_display_id/field-displays/:field_display_id/data-displays', to: 'flats#index'
 get '/', to: 'flats#index'
  resources :textareas, path: '/mega-bar/textareas'
   ##### MEGABAR END ##### 
end




def blck
  MegaBar::Block.first
end

def get_env(args)

  env = Rack::MockRequest.env_for(args[:uri], params: args[:params])
  env[:mega_page] = args[:page]
  env[:mega_rout] = args[:rout]
  env[:mega_env] = MegaEnv.new(blck, args[:rout], args[:page]).to_hash # added to env for use in controllers
  request = Rack::Request.new(env)
  request.session[:return_to] = uri;
  env
end

def params_for_index
end

RSpec::Matchers.define :have_same_attributes_as do |expected|
  match do |actual|
    ignored = [:id, :updated_at, :created_at]
    actual.attributes.except(*ignored) == expected.attributes.except(*ignored)
  end
end
