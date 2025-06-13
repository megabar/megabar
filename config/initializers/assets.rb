# Rails 8+ no longer supports config.assets. This file is now disabled.
# If you need asset management, use Propshaft, jsbundling-rails, or importmap-rails.

# Previous asset pipeline config (now disabled):
# Rails.application.config.assets.paths << Rails.root.join("app", "assets", "stylesheets")
# Rails.application.config.assets.paths << Rails.root.join("app", "assets", "javascripts")
# Rails.application.config.assets.precompile += %w( mega_bar.css )

# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
# Rails.application.config.assets.version = '1.0'

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )

# Rails.application.config.assets.precompile += %w( mega_bar/mega_bar.css )

# Add additional paths to the asset load paths.
Rails.application.config.assets.paths << Rails.root.join("app", "assets", "stylesheets")
Rails.application.config.assets.paths << Rails.root.join("app", "assets", "javascripts")

# Add additional assets to the precompile list.
Rails.application.config.assets.precompile += %w( mega_bar.css mega_bar.js )
