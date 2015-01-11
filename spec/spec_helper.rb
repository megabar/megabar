ENV['RAILS_ENV'] ||= 'test'
# require File.expand_path("../test_app/config/environment.rb",  __FILE__)
require 'rspec/rails'
require 'factory_girl_rails'
require 'combustion'
require 'capybara' # capybara/rspec? capybar/rails?
Combustion.initialize! :all

require 'pry'
Rails.backtrace_cleaner.remove_silencers!
# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
RSpec.configure do |config|
  config.mock_with :rspec
  config.use_transactional_fixtures = true
  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"
end



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
