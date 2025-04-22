$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'mega_bar/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'mega_bar'
  s.version     = MegaBar::VERSION
  s.authors     = ['Bagus']
  s.email       = ['bagus@bagus.org']
  s.homepage    = 'http://www.github.com/tomochiart/mega_bar'
  s.summary     = ' MegaBar.'
  s.description = 'Rails GUI.'
  s.license     = 'MIT'
  s.files = Dir['{app,config,db,lib}/**/*', 'spec/internal/factories/**/*', 'MIT-LICENSE', 'Rakefile', 'README.rdoc']
  # s.add_development_dependency 'rspec', '~> 2.6'
  # s.add_development_dependency 'rspec-rails'
  s.add_dependency 'acts_as_list'
  s.add_dependency 'bootstrap', '~> 5.3.0'
  # s.add_dependency 'best_in_place', 'https://github.com/mmotherwell/best_in_place'
  s.add_dependency 'jquery-ui-rails'
  s.add_dependency 'kaminari'
  s.add_dependency 'rails'
  s.add_dependency 'seed_dump'
  s.add_dependency 'seedbank'
  s.add_dependency 'slim-rails'
  s.add_dependency 'nandi'
  s.add_development_dependency 'aruba'
  s.add_development_dependency 'bundler' # , '~> 1.7'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'combustion', '~> 1.3'
  # s.add_development_dependency 'cucumber'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'pry-doc'
  s.add_development_dependency 'pry-rails'
  s.add_development_dependency 'pry-stack_explorer'
  s.add_development_dependency 'rake', '~> 13.0'
  s.add_development_dependency 'rspec-core'
  s.add_development_dependency 'webmock'
  s.test_files = Dir['spec/**/*']
end

