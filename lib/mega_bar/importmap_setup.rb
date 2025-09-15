# MegaBar Engine Importmap Setup for Rails 8+
module MegaBar
  class ImportmapSetup
    def self.configure_host_app(app)
      return unless defined?(Importmap::Map)
      
      # Pin jQuery and dependencies
      app.config.importmap.pin "jquery", to: "https://ga.jspm.io/npm:jquery@3.7.1/dist/jquery.js"
      app.config.importmap.pin "autosize", to: "https://ga.jspm.io/npm:autosize@6.0.1/dist/autosize.esm.js"
      
      # Pin MegaBar engine modules
      app.config.importmap.pin "mega_bar/add_jquery", to: "mega_bar/add_jquery.js"
      app.config.importmap.pin "mega_bar/application", to: "mega_bar/application.js"
      app.config.importmap.pin "mega_bar/best_in_place", to: "mega_bar/best_in_place.js"
      app.config.importmap.pin "mega_bar/tabs", to: "mega_bar/tabs.js"
      app.config.importmap.pin "mega_bar/layout", to: "mega_bar/layout.js"
      
      Rails.logger.info "MegaBar: Importmap configured for Rails 8 compatibility"
    end
    
    def self.setup_host_application_js(app_root)
      app_js_path = File.join(app_root, 'app', 'javascript', 'application.js')
      
      if File.exist?(app_js_path)
        content = File.read(app_js_path)
        
        # Check if MegaBar import already exists
        unless content.include?('mega_bar/application')
          # Add MegaBar import
          megabar_import = "\n// MegaBar Engine JavaScript\nimport \"mega_bar/application\";\n"
          
          # Insert after existing imports but before any initialization code
          if content.include?('import "controllers"')
            content = content.sub('import "controllers";', "import \"controllers\";\n#{megabar_import}")
          else
            content += megabar_import
          end
          
          File.write(app_js_path, content)
          Rails.logger.info "MegaBar: Added import to #{app_js_path}"
        end
      end
    end
  end
end
