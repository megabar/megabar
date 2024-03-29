#!/usr/bin/env ruby
# frozen_string_literal: true

begin
  require 'bundler/setup'
rescue LoadError => e
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
  raise e unless ENV['RAILS_ENV'] == "production"
end

begin
  require 'byebug'
rescue LoadError => e
  raise e unless ENV['RAILS_ENV'] == "production"
end

begin
  require 'rdoc/task'
rescue LoadError => e
  raise e unless ENV['RAILS_ENV'] == "production"
end

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'MegaBar'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

Bundler::GemHelper.install_tasks

APP_RAKEFILE = File.expand_path("../spec/dummy/Rakefile", __FILE__)
load 'rails/tasks/engine.rake'
Bundler::GemHelper.install_tasks
Dir[File.join(File.dirname(__FILE__), 'tasks/**/*.rake')].each {|f| load f }

begin
  require 'rspec/core'
  require 'rspec/core/rake_task'
rescue LoadError => e
  raise e unless ENV['RAILS_ENV'] == "production"
end

desc "Run all specs in spec directory (excluding plugin specs)"
RSpec::Core::RakeTask.new(:spec => 'app:db:test:prepare')
task :default => :spec
