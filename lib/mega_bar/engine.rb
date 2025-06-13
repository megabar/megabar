module MegaBar
  class Engine < ::Rails::Engine
    isolate_namespace MegaBar
    require 'seed_dump'
    require 'best_in_place'
    require 'acts_as_list'

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
      FactoryBot.definition_file_paths << File.expand_path('../../../spec/factories', __FILE__) if defined?(FactoryBot)
    end

    initializer "mega_bar.assets" do |app|
      # Add asset paths
      app.config.assets.paths << root.join("app", "assets", "javascripts")
      app.config.assets.paths << root.join("app", "assets", "stylesheets")
      app.config.assets.paths << root.join("app", "assets", "images")

      # Precompile assets
      app.config.assets.precompile += %w( mega_bar/mega_bar.css )
      app.config.assets.precompile += %w( mega_bar/mega_block_tabs.css )
      app.config.assets.precompile += %w( mega_bar/tabs.js )
      app.config.assets.precompile += %w( mega_bar/layout.js )
      app.config.assets.precompile += %w( mega_bar/jquery.best_in_place.js )
      app.config.assets.precompile += %w( mega_bar/best_in_place.js )
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
