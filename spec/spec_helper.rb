ENV['RAILS_ENV'] ||= 'test'

# Suppress DidYouMean deprecation warnings
Warning[:deprecated] = false

# Suppress specific DidYouMean warnings
original_warn = Warning.method(:warn)
Warning.define_singleton_method(:warn) do |message|
  return if message.include?('DidYouMean::SPELL_CHECKERS.merge!')
  original_warn.call(message)
end

require 'byebug'
require 'rubygems'
require 'bundler/setup'
require 'pry'
require 'combustion'
require 'capybara/rspec'
require 'simplecov'
# require 'rake'
require 'rails/all'
require 'acts_as_list'

require 'rspec/rails'
require 'bundler'

Bundler.require :default, :development

# require File.expand_path("../../spec/internal/config/environment", __FILE__)


# SimpleCov.start
begin
  Combustion.initialize! :active_record, :action_controller, :action_view
rescue => e
  puts "⚠️  Combustion error: #{e.message}"
  puts "🔄 Trying alternative initialization..."
  # Fallback to basic Rails initialization
  require 'rails'
  require 'active_record'
  require 'action_controller'
  require 'action_view'
end

# Require MegaBar specific classes needed for testing
require_relative '../lib/mega_bar/mega_env'

# Ensure MegaBar models, controllers, helpers, and concerns are loaded before database cleanup
begin
  # Load all MegaBar models
  Dir[File.expand_path('../app/models/mega_bar/*.rb', __FILE__)].each { |f| require f }
  
  # Also try to load models from the engine path
  engine_models_path = File.expand_path('../../app/models/mega_bar/*.rb', __FILE__)
  Dir[engine_models_path].each { |f| require f } if Dir.exist?(File.dirname(engine_models_path))
  
  # Load all MegaBar helpers
  Dir[File.expand_path('../app/helpers/mega_bar/*.rb', __FILE__)].each { |f| require f }
  
  # Also try to load helpers from the engine path
  engine_helpers_path = File.expand_path('../../app/helpers/mega_bar/*.rb', __FILE__)
  Dir[engine_helpers_path].each { |f| require f } if Dir.exist?(File.dirname(engine_helpers_path))
  
  # Load MegaBarConcern first (it's a dependency for other controllers)
  concern_file = File.expand_path('../app/controllers/mega_bar/mega_bar_concern.rb', __FILE__)
  require concern_file if File.exist?(concern_file)
  
  # Also try to load from engine path
  engine_concern_file = File.expand_path('../../app/controllers/mega_bar/mega_bar_concern.rb', __FILE__)
  require engine_concern_file if File.exist?(engine_concern_file)
  
  # Load all MegaBar concerns
  Dir[File.expand_path('../app/controllers/mega_bar/concerns/*.rb', __FILE__)].each { |f| require f }
  
  # Also try to load concerns from the engine path
  engine_concerns_path = File.expand_path('../../app/controllers/mega_bar/concerns/*.rb', __FILE__)
  Dir[engine_concerns_path].each { |f| require f } if Dir.exist?(File.dirname(engine_concerns_path))
  
  # Load all MegaBar controllers (after helpers and concerns are loaded)
  Dir[File.expand_path('../app/controllers/mega_bar/*.rb', __FILE__)].each { |f| require f }
  
  # Also try to load controllers from the engine path
  engine_controllers_path = File.expand_path('../../app/controllers/mega_bar/*.rb', __FILE__)
  Dir[engine_controllers_path].each { |f| require f } if Dir.exist?(File.dirname(engine_controllers_path))
rescue => e
  puts "⚠️  Could not load MegaBar models/controllers/helpers/concerns: #{e.message}"
end

# after combustion has initialized the routes, we have to delete all the data
# that the seeds added so that the tests run with empty databases.
begin
  MegaBar::Page.connection.execute('delete from mega_bar_pages')
  MegaBar::Page.connection.execute('delete from sqlite_sequence where name="mega_bar_pages"')
  MegaBar::Layout.connection.execute('delete from mega_bar_layouts')
  MegaBar::Layout.connection.execute('delete from sqlite_sequence where name="mega_bar_layouts"')
  MegaBar::Layable.connection.execute('delete from mega_bar_layables')
  MegaBar::Layable.connection.execute('delete from sqlite_sequence where name="mega_bar_layables"')
  MegaBar::LayoutSection.connection.execute('delete from mega_bar_layout_sections')
  MegaBar::LayoutSection.connection.execute('delete from sqlite_sequence where name="mega_bar_layout_sections"')
  MegaBar::Block.connection.execute('delete from mega_bar_blocks')
  MegaBar::Block.connection.execute('delete from sqlite_sequence where name="mega_bar_blocks"')
  MegaBar::ModelDisplay.connection.execute('delete from mega_bar_model_displays')
  MegaBar::ModelDisplay.connection.execute('delete from sqlite_sequence where name="mega_bar_model_displays"')
  MegaBar::Model.connection.execute('delete from mega_bar_models')
  MegaBar::Model.connection.execute('delete from sqlite_sequence where name="mega_bar_models"')
rescue => e
  puts "⚠️  Could not clean up database: #{e.message}"
end

require 'rspec/rails'
require 'capybara/rails'

# Configure FactoryBot to use the correct factories directory before loading factory_bot_rails
FactoryBot.definition_file_paths = [
  File.expand_path('../internal/factories', __FILE__),
  File.expand_path('../internal/test_factories', __FILE__)
]
require 'factory_bot_rails'

# Manually load factory files (FactoryBot auto-loading doesn't work reliably in test environment)
FactoryBot.definition_file_paths.each do |path|
  if Dir.exist?(path)
    Dir[File.join(path, '*.rb')].each do |factory_file|
      load factory_file
    end
  end
end


Rails.backtrace_cleaner.remove_silencers!
# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
RSpec.configure do |config|
  config.mock_with :rspec
  config.use_transactional_fixtures = true
  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"
  config.include FactoryBot::Syntax::Methods
  
  # Clean up test migrations after all specs complete
  config.after(:suite) do
    # Clean up test-specific migrations
    test_migration_dir = File.expand_path('../internal/db/migrate', __FILE__)
    if Dir.exist?(test_migration_dir)
      Dir.glob(File.join(test_migration_dir, '*.rb')).each do |migration_file|
        File.delete(migration_file)
        puts "🧹 Cleaned up test migration: #{File.basename(migration_file)}"
      end
    end
    
    # Clean up test-generated factories
    test_factories_dir = File.expand_path('../internal/test_factories', __FILE__)
    if Dir.exist?(test_factories_dir)
      Dir.glob(File.join(test_factories_dir, '*.rb')).each do |factory_file|
        File.delete(factory_file)
        puts "🧹 Cleaned up test factory: #{File.basename(factory_file)}"
      end
      # Remove empty directory
      Dir.rmdir(test_factories_dir) if Dir.exist?(test_factories_dir) && Dir.empty?(test_factories_dir)
    end
    
    # Clean up any test migrations that might have been created in main db/migrate
    main_migration_dir = File.expand_path('../db/migrate', __FILE__)
    if Dir.exist?(main_migration_dir)
      Dir.glob(File.join(main_migration_dir, '*_create_*.rb')).each do |migration_file|
        # Only delete migrations created during this test run (today's date)
        if File.basename(migration_file).start_with?(Time.now.strftime('%Y%m%d'))
          File.delete(migration_file)
          puts "🧹 Cleaned up main migration: #{File.basename(migration_file)}"
        end
      end
    end
    
    # Clean up any test-generated files that might have been created in wrong places
    test_internal_dir = File.expand_path('../internal', __FILE__)
    
    # Clean up test-generated app files (controllers, models)
    ['app/controllers', 'app/models'].each do |app_dir|
      full_app_dir = File.join(test_internal_dir, app_dir)
      if Dir.exist?(full_app_dir)
        Dir.glob(File.join(full_app_dir, '**/*.rb')).each do |file|
          File.delete(file)
          puts "🧹 Cleaned up test-generated file: #{file}"
        end
        # Remove empty directories
        Dir.glob(File.join(full_app_dir, '**/*')).reverse.each do |dir|
          Dir.rmdir(dir) if Dir.exist?(dir) && Dir.empty?(dir)
        end
      end
    end
    
    # Clean up test-generated spec files (but keep factories)
    spec_dir = File.join(test_internal_dir, 'spec')
    if Dir.exist?(spec_dir)
      ['controllers', 'models'].each do |spec_subdir|
        full_spec_subdir = File.join(spec_dir, spec_subdir)
        if Dir.exist?(full_spec_subdir)
          Dir.glob(File.join(full_spec_subdir, '**/*.rb')).each do |file|
            File.delete(file)
            puts "🧹 Cleaned up test-generated spec file: #{file}"
          end
          # Remove empty directories
          Dir.glob(File.join(full_spec_subdir, '**/*')).reverse.each do |dir|
            Dir.rmdir(dir) if Dir.exist?(dir) && Dir.empty?(dir)
          end
        end
      end
    end
  end
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
  # Use the first available block or create one
  MegaBar::Block.first || FactoryBot.create(:block)
end

def get_env(args)
  env = Rack::MockRequest.env_for(args[:uri], params: args[:params])
  env[:mega_page] = args[:page]
  env[:mega_rout] = args[:rout]
  env[:mega_env] = MegaBar::MegaEnv.new(blck, args[:rout], args[:page], []).to_hash # added to env for use in controllers
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
