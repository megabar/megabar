module MegaBar
  class Engine < ::Rails::Engine
    isolate_namespace MegaBar
    require 'seed_dump'
    require 'best_in_place'
    require 'acts_as_list'
    require 'devise'

    config.autoload_paths << File.expand_path("../*", __FILE__)


    require File.expand_path('../mega_route.rb', __FILE__)

    require File.expand_path('../layout_engine.rb', __FILE__)
    config.app_middleware.use LayoutEngine



    initializer :append_migrations do |app|
      unless app.root.to_s.match root.to_s
        config.paths["db/migrate"].expanded.each do |expanded_path|
          app.config.paths["db/migrate"] << expanded_path
        end
      end
    end

    initializer "model_core.factories", :after => "factory_girl.set_factory_paths" do
      FactoryGirl.definition_file_paths << File.expand_path('../../../spec/factories', __FILE__) if defined?(FactoryGirl)
    end
    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
      g.assets false
      g.helper false
    end
    ### taskrabbit: http://tech.taskrabbit.com/blog/2014/02/11/rails-4-engines/
    ### http://pivotallabs.com/leave-your-migrations-in-your-rails-engines/

    config.action_view.logger = nil

  end
end

# class DynamicRouter
#   def self.load
#     # abort('llll diedddd')
#     MegaBar::Application.routes.draw do
#       MegaBar::Page.all.each do |pg|
#         puts "page path: " + pg.path
#         MegaBar::Layout.all.each do |layout|
#           MegaBar::Block.all.each do | block |
#             puts "Routing #{pg.name}"
#             get "/#{pg.name}", :to => "pages#show", defaults: { id: pg.id }
#           end
#         end
#       end
#     end
#   end

#   def self.reload
#     ComingSoon::Application.routes_reloader.reload!
#   end
# end
