module MegaBar
  module AuthorizationConcern
    extend ActiveSupport::Concern

    included do
      # Only include CCCUX if it's available
      if defined?(Cccux::ApplicationControllerConcern)
        include Cccux::ApplicationControllerConcern
        
        # Only set up authorization for controllers that have models
        # Skip ApplicationController and other base controllers
        unless self.name.end_with?('ApplicationController')
          setup_authorization
        end
      end
    end

    class_methods do
      def setup_authorization
        # Determine the model class from the controller name
        model_class = determine_model_class
        
        # Set up load_and_authorize_resource if CCCUX is available
        if model_class && defined?(CanCan::Ability)
          load_and_authorize_resource class: model_class, except: [:administer_block, :administer_page]
        end
      end

      def determine_model_class
        # Extract the model name from the controller class name
        controller_name = self.name
        model_name = controller_name.gsub(/Controller$/, '').split('::').last
        
        # Convert to singular and classify
        # e.g., Models -> Model, Pages -> Page, Dogs -> Dog
        singular_model = model_name.singularize
        
        # Try multiple possible class names:
        # 1. MegaBar::Model (for MegaBar controllers)
        # 2. Just Model (for host app controllers)
        possible_class_names = [
          "MegaBar::#{singular_model}",
          singular_model
        ]
        
        possible_class_names.each do |full_class_name|
          if Object.const_defined?(full_class_name)
            return full_class_name.constantize
          end
        end
        
        Rails.logger.warn "MegaBar::AuthorizationConcern: Could not determine model class for #{controller_name}. Tried: #{possible_class_names.join(', ')}"
        nil
      rescue => e
        Rails.logger.warn "MegaBar::AuthorizationConcern: Error determining model class: #{e.message}"
        nil
      end
    end
  end
end 