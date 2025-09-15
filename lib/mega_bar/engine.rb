module MegaBar
  class Engine < ::Rails::Engine
    isolate_namespace MegaBar
    require 'seed_dump'
    require 'acts_as_list'
    require "importmap-rails"


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

    initializer "mega_bar.assets", after: :append_assets_path do |app|
      # Add engine's asset paths to the host application's load path
      # This handles both Sprockets (pre-Rails 8) and Propshaft (Rails 8+)
      app.config.assets.paths << root.join("app", "assets")
      app.config.assets.paths << root.join("app/javascript")
    end

    # initializer "mega_bar.importmap", before: "importmap" do |app|
    #   # Add the engine's importmap.rb to the host application's importmap paths
    #   app.config.importmap.paths << root.join("config/importmap.rb")

    #   # Tell the host application's asset pipeline where to find the JavaScript files
    #   app.config.assets.paths << root.join("app/javascript")
    # end

    


    # initializer "mega_bar.assets" do |app|
    #   # For Sprockets/Propshaft, add the traditional asset paths
    #   app.config.assets.paths << root.join("app", "assets")

    #   # For Rails 8+ Importmap, add the modern javascript path.
    #   # This allows the host app to find the engine's JS modules.
    #   if defined?(Importmap)
    #     app.config.assets.paths << root.join("app/javascript")
    #   end
    # end

    initializer "model_core.factories", :after => "factory_girl.set_factory_paths" do
      FactoryBot.definition_file_paths << File.expand_path('../../../spec/factories', __FILE__) if defined?(FactoryBot)
    end

    # initializer "mega_bar.best_in_place" do |app|
    #   # Configure best_in_place
    #   app.config.after_initialize do
    #     BestInPlace.configure do |config|
    #       # config.activate = true
    #       config.activate_for = [:text, :textarea, :select, :checkbox]
    #     end
    #   end
    # end

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
      g.helper false
    end

    config.action_view.logger = nil
    config.annotate_rendered_view_with_filenames = false
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
