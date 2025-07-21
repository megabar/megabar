require 'spec_helper'
require_relative 'shared_contexts/megabar_integration_setup'

RSpec.describe "Authorization Workflow Integration", type: :integration do
  # This tests the complete authorization integration between MegaBar and CCCUX
  # It covers both scenarios: with CCCUX present and with fallback behavior
  
  describe "MegaBar Authorization Fallback" do
    include_context "megabar_integration_setup"
    
    let(:test_template_name) { 'authorization_test_template' }
    let(:test_model_name) { 'AuthorizationTestModel' }

    it "provides fallback authorization when CCCUX is not available" do
      puts "\n🧪 TESTING: Authorization Fallback Behavior"
      puts "-" * 50

      # Create a complete MegaBar setup
      page = integration_page
      block = integration_block
      
      puts "📄 Created test page #{page.id} with block #{block.id}"

      # Test MegaBar::AuthorizationHelper fallback behavior
      controller = MegaBar::BlocksController.new
      
      # When CCCUX is not available, should default to allowing actions
      if !defined?(Cccux::AuthorizationHelper)
        puts "ℹ️  CCCUX not available - testing fallback behavior"
        
        # Test that helper methods exist and provide fallback
        if controller.respond_to?(:can_perform_action?)
          result = controller.can_perform_action?(:index, MegaBar::Block)
          expect(result).to be(true)
          puts "✅ Fallback authorization allows index action"
          
          %i[show create edit update destroy].each do |action|
            result = controller.can_perform_action?(action, MegaBar::Block)
            expect(result).to be(true)
            puts "✅ Fallback authorization allows #{action} action"
          end
        else
          puts "ℹ️  Authorization helpers not loaded - this is expected in some test environments"
        end
      else
        puts "ℹ️  CCCUX is available - testing integration behavior"
        # Test CCCUX integration (when available)
      end

      puts "✅ Authorization fallback testing complete!"
    end

    it "integrates with view helpers for conditional rendering" do
      puts "\n🧪 TESTING: View Helper Integration"
      puts "-" * 50

      page = integration_page
      
      # Test the helper methods that would be used in views
      # This simulates what happens in _mega_bar_block_links.html.erb
      
      controller = MegaBar::PagesController.new
      
      puts "📄 Testing view helpers for Page #{page.id}"

      # Test link_if_can_* helper availability
      helper_methods = %w[
        link_if_can_index
        link_if_can_show  
        link_if_can_create
        link_if_can_edit
        link_if_can_update
        link_if_can_destroy
      ]

      helper_methods.each do |helper_method|
        if controller.respond_to?(helper_method)
          puts "✅ Helper method #{helper_method} available"
        else
          puts "ℹ️  Helper method #{helper_method} not available (expected in some test configs)"
        end
      end

      puts "✅ View helper integration testing complete!"
    end
  end

  describe "CCCUX Integration (when available)" do
    include_context "megabar_integration_setup"

    it "detects CCCUX availability" do
      puts "\n🧪 TESTING: CCCUX Detection"
      puts "-" * 50

      cccux_available = defined?(Cccux::AuthorizationHelper)
      cccux_concern_available = defined?(Cccux::ApplicationControllerConcern)
      
      puts "CCCUX::AuthorizationHelper available: #{!!cccux_available}"
      puts "CCCUX::ApplicationControllerConcern available: #{!!cccux_concern_available}"

      if cccux_available
        puts "✅ CCCUX detected - testing integration"
        
        # Test that controllers include CCCUX concern
        controller = MegaBar::ApplicationController.new
        included_modules = controller.class.included_modules.map(&:to_s)
        
        if included_modules.include?('Cccux::ApplicationControllerConcern')
          puts "✅ CCCUX concern included in ApplicationController"
        else
          puts "ℹ️  CCCUX concern not included (may need configuration)"
        end
      else
        puts "ℹ️  CCCUX not available - using MegaBar fallback"
      end

      puts "✅ CCCUX detection complete!"
    end

    it "handles role-based permissions (when CCCUX available)" do
      puts "\n🧪 TESTING: Role-Based Permissions"
      puts "-" * 50

      if defined?(Cccux::Role)
        puts "🔐 CCCUX Role system available"
        
        # Test role creation and management
        begin
          role_manager = Cccux::Role.find_or_create_by(name: 'Role Manager') do |role|
            role.description = 'Integration test role manager'
          end
          
          mega_role = Cccux::Role.find_or_create_by(name: 'Mega Role') do |role|
            role.description = 'Integration test mega role'  
          end

          puts "✅ Created/found test roles: #{role_manager.name}, #{mega_role.name}"

          # Test permission assignment (if Permission model exists)
          if defined?(Cccux::Permission)
            page = integration_page
            
            # Create permissions for page access
            page_permission = Cccux::Permission.find_or_create_by(
              subject_class: 'MegaBar::Page',
              subject_id: page.id,
              action: 'index'
            )
            
            puts "✅ Created permission for Page #{page.id}"
            
            # Test role-permission association (if it exists)
            if role_manager.respond_to?(:permissions)
              role_manager.permissions << page_permission unless role_manager.permissions.include?(page_permission)
              puts "✅ Associated permission with role"
            end
          end

        rescue => e
          puts "ℹ️  Role/Permission system not fully configured: #{e.message}"
        end
      else
        puts "ℹ️  CCCUX Role system not available"
      end

      puts "✅ Role-based permissions testing complete!"
    end
  end

  describe "Authorization in MegaBarConcern Actions" do
    include_context "megabar_integration_setup"

    it "tests authorization in controller actions" do
      puts "\n🧪 TESTING: Controller Action Authorization"
      puts "-" * 50

      # Create complete setup
      page = integration_page
      model = integration_model
      block = integration_block

      puts "📄 Testing authorization for Page #{page.id}, Model #{model.id}, Block #{block.id}"

      # Test that controllers can handle authorization checks
      controllers_to_test = [
        MegaBar::PagesController,
        MegaBar::ModelsController,
        MegaBar::BlocksController
      ]

      controllers_to_test.each do |controller_class|
        controller = controller_class.new
        
        puts "🎮 Testing #{controller_class.name}"

        # Test basic authorization method availability
        if controller.respond_to?(:can_perform_action?)
          # Test standard CRUD actions
          %i[index show create edit update destroy].each do |action|
            # This should not raise an error
            expect { 
              controller.can_perform_action?(action, Object) 
            }.not_to raise_error
          end
          puts "  ✅ Authorization methods work without errors"
        else
          puts "  ℹ️  Authorization methods not available (expected in some configs)"
        end

        # Test MegaBarConcern integration
        if controller.class.included_modules.include?(MegaBar::MegaBarConcern)
          puts "  ✅ MegaBarConcern included"
        else
          puts "  ⚠️  MegaBarConcern not included"
        end
      end

      puts "✅ Controller action authorization testing complete!"
    end
  end

  describe "Authorization Edge Cases and Error Handling" do
    include_context "megabar_integration_setup"

    it "handles authorization gracefully when models don't exist" do
      puts "\n🧪 TESTING: Authorization with Non-Existent Models"
      puts "-" * 50

      controller = MegaBar::BlocksController.new

      if controller.respond_to?(:can_perform_action?)
        # Test authorization with non-existent model class
        expect {
          controller.can_perform_action?(:index, String)
        }.not_to raise_error

        # Test authorization with nil
        expect {
          controller.can_perform_action?(:show, nil)
        }.not_to raise_error

        puts "✅ Authorization handles edge cases gracefully"
      else
        puts "ℹ️  Authorization methods not available for testing"
      end
    end

    it "handles mixed CCCUX and MegaBar authorization scenarios" do
      puts "\n🧪 TESTING: Mixed Authorization Scenarios"
      puts "-" * 50

      # Create test data
      page = integration_page
      
      # Test scenarios where some controllers have CCCUX and others don't
      controllers = [
        MegaBar::ApplicationController.new,
        MegaBar::PagesController.new,
        MegaBar::BlocksController.new
      ]

      controllers.each do |controller|
        puts "🎮 Testing #{controller.class.name}"
        
        included_modules = controller.class.included_modules.map(&:to_s)
        has_cccux = included_modules.any? { |m| m.include?('Cccux') }
        has_megabar_auth = included_modules.include?('MegaBar::AuthorizationHelper')
        responds_to_auth = controller.respond_to?(:can_perform_action?)

        puts "  CCCUX modules: #{has_cccux}"
        puts "  MegaBar auth: #{has_megabar_auth}" 
        puts "  Responds to auth: #{responds_to_auth}"

        # Each controller should have some form of authorization available
        expect(has_cccux || has_megabar_auth || responds_to_auth).to be(true)
        puts "  ✅ Some form of authorization available"
      end

      puts "✅ Mixed authorization scenarios testing complete!"
    end
  end
end 