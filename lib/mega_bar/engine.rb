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
      # Rails 8 CSS assets
      app.config.assets.paths << root.join('app', 'assets', 'stylesheets')
      app.config.assets.paths << root.join('app', 'assets', 'images')
      
      # Precompile MegaBar CSS
      app.config.assets.precompile += %w( 
        mega_bar/application.css
        mega_bar/mega_bar.css 
        mega_bar/mega_block_tabs.css 
      )
    end

    initializer "mega_bar.importmap", before: "importmap" do |app|
      # Integrate MegaBar's importmap with host application
      if defined?(Importmap::Map)
        app.config.importmap.paths << root.join("config/importmap.rb")
        app.config.importmap.cache_sweepers << root.join("app/javascript")
        Rails.logger.info "MegaBar: Integrated engine importmap with host application"
      end
    end

    initializer "mega_bar.assets", after: "append_assets_path" do |app|
      # Add engine's JavaScript path to asset paths for Propshaft
      app.config.assets.paths << root.join("app/javascript")
      
      # Auto-generate engine files in host app when Rails starts
      Rails.application.config.after_initialize do
        # Auto-generate add_jquery.js if it doesn't exist
        add_jquery_path = Rails.root.join('app', 'javascript', 'add_jquery.js')
        unless File.exist?(add_jquery_path)
          FileUtils.mkdir_p(File.dirname(add_jquery_path))
          File.write(add_jquery_path, File.read(root.join('app', 'javascript', 'mega_bar', 'add_jquery.js')))
          Rails.logger.info "MegaBar: Created add_jquery.js from engine"
        end
        
        # Auto-generate best_in_place.js if it doesn't exist
        best_in_place_path = Rails.root.join('app', 'javascript', 'best_in_place.js')
        unless File.exist?(best_in_place_path)
          FileUtils.mkdir_p(File.dirname(best_in_place_path))
          File.write(best_in_place_path, File.read(root.join('app', 'javascript', 'mega_bar', 'best_in_place.js')))
          Rails.logger.info "MegaBar: Created best_in_place.js from engine"
        end
      end
      
      Rails.logger.info "MegaBar: Added engine JavaScript assets to host application"
    end

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
