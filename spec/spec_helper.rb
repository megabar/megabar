ENV['RAILS_ENV'] ||= 'test'
require 'byebug'
require 'rubygems'
require 'bundler/setup'
require 'pry'
require 'combustion'
require 'capybara/rspec'
require 'simplecov'
require 'rake'
require 'rails/all'
require 'acts_as_list'

SimpleCov.start
Combustion.initialize! :all do
  # Megabar dyamically generates routes based on data in the db.
  # So we'll load all the data here so the routes are generated properly
  # but then we'll have to delete all the data so the tests run on an empty db
  # like a normal test suite would.
  load File.expand_path("../../lib/tasks/mega_bar_tasks.rake", __FILE__)
  Rake::Task.define_task(:environment)
  Rake::Task['mega_bar:data_load'].invoke('../../db/mega_bar.seeds.rb', 'routes')
end
# after combustion has initialized the routes, we have to delete all the data
# that the seeds added so that the tests run with empty databases.
MegaBar::Page.connection.execute('delete from mega_bar_pages')
MegaBar::Page.connection.execute('delete from sqlite_sequence where name="mega_bar_pages"')
MegaBar::Layout.connection.execute('delete from mega_bar_layouts')
MegaBar::Layout.connection.execute('delete from sqlite_sequence where name="mega_bar_layouts"')
MegaBar::Block.connection.execute('delete from mega_bar_blocks')
MegaBar::Block.connection.execute('delete from sqlite_sequence where name="mega_bar_blocks"')
MegaBar::ModelDisplay.connection.execute('delete from mega_bar_model_displays')
MegaBar::ModelDisplay.connection.execute('delete from sqlite_sequence where name="mega_bar_model_displays"')
MegaBar::Model.connection.execute('delete from mega_bar_models')
MegaBar::Model.connection.execute('delete from sqlite_sequence where name="mega_bar_models"')

require 'rspec/rails'
require 'capybara/rails'
require 'factory_girl_rails'


Rails.backtrace_cleaner.remove_silencers!
# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
RSpec.configure do |config|
  config.mock_with :rspec
  config.use_transactional_fixtures = true
  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"
  config.include FactoryGirl::Syntax::Methods
end

def hello_bob
  'hello bob'
end
# binding.pry
#require 'rake'
#load File.expand_path("../../lib/tasks/mega_bar_tasks.rake", __FILE__)
#Rake::Task.define_task(:environment)
#Rake::Task['mega_bar:data_load'].invoke('../../db/mega_bar.seeds.rb')

=begin
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

ActiveRecord::Schema.define(:version => 1) do
  create_table :mega_bar_field_displays do |t|
    t.integer :field_id
    t.string :format
    t.string :action
    t.string :header
  end
end
=end

def blck
  MegaBar::Block.find(1)
end

def get_env(args)
  env = Rack::MockRequest.env_for(args[:uri], params: args[:params])
  env[:mega_page] = args[:page]
  env[:mega_rout] = args[:rout]
  env[:mega_env] = MegaEnv.new(blck, args[:rout], args[:page], []).to_hash # added to env for use in controllers
  request = Rack::Request.new(env)
  request.session[:return_to] = url_for(uri);
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
