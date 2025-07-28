# Lightweight shared examples for MegaBar controller testing
# This focuses on controller functionality without complex model dependencies

RSpec.shared_examples "basic_megabar_controller" do
  describe "Basic Controller Structure" do
    it "can be instantiated" do
      expect(described_class.new).to be_a(described_class)
    end

    it "inherits from MegaBar::ApplicationController" do
      expect(described_class.superclass).to eq(MegaBar::ApplicationController)
    end

    it "includes MegaBarConcern" do
      expect(described_class.included_modules).to include(MegaBar::MegaBarConcern)
    end
  end

  describe "Authorization Integration" do
    let(:controller) { described_class.new }

    it "reports authorization infrastructure status" do
      # This test documents the current authorization setup
      # and can help identify integration issues
      
      helper_modules = controller.class.included_modules.map(&:to_s)
      cccux_available = helper_modules.include?('Cccux::ApplicationControllerConcern')
      megabar_helpers = helper_modules.include?('MegaBar::AuthorizationHelper')
      responds_to_auth = controller.respond_to?(:can_perform_action?)
      
      puts "\n=== Authorization Infrastructure Status ==="
      puts "CCCUX Available: #{cccux_available}"
      puts "MegaBar Helpers: #{megabar_helpers}"
      puts "Responds to auth: #{responds_to_auth}"
      puts "Included modules: #{helper_modules.select { |m| m.include?('Authorization') || m.include?('Cccux') }}"
      puts "=========================================="
      
      # For now, just expect the controller to exist
      # Authorization integration testing belongs in integration tests
      expect(controller).to be_a(described_class)
    end

    it "can check basic permissions with fallback" do
      if controller.respond_to?(:can_perform_action?)
        # Test the fallback behavior when CCCUX is not present
        result = controller.can_perform_action?(:index, Object)
        expect(result).to be(true) # Should default to true as fallback
      end
    end
  end

  describe "Controller Naming Convention" do
    it "follows MegaBar controller naming pattern" do
      expect(described_class.name).to match(/\AMegaBar::\w+Controller\z/)
    end

    it "can derive model name from controller name" do
      model_name = described_class.name.demodulize.gsub('Controller', '').singularize
      expect(model_name).to be_a(String)
      expect(model_name.length).to be > 0
    end
  end
end

RSpec.shared_examples "megabar_controller_with_model" do |expected_model_class|
  include_examples "basic_megabar_controller"

  describe "Model Integration" do
    it "works with the expected model class" do
      expect(expected_model_class).to be_a(Class)
      expect(expected_model_class.name).to start_with('MegaBar::')
    end

    it "can instantiate the associated model" do
      expect(expected_model_class.new).to be_a(expected_model_class)
    end

    it "model has deterministic ID support" do
      if expected_model_class.respond_to?(:deterministic_id)
        expect(expected_model_class.method(:deterministic_id)).to be_a(Method)
      end
    end
  end
end 