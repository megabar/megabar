ENV["RAILS_ENV"] ||= "test"
require "rubygems"
require "bundler/setup"
require "combustion"
require "rails/all"
require "acts_as_list"

Combustion.initialize! :all

require "rails/test_help"
require "mega_bar"

# Clean up any test data using database-agnostic methods
MegaBar::Page.delete_all
MegaBar::Layout.delete_all
MegaBar::Layable.delete_all
MegaBar::LayoutSection.delete_all
MegaBar::Block.delete_all
MegaBar::ModelDisplay.delete_all
MegaBar::Model.delete_all 