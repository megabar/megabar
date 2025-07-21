# MegaBar Controller Structure Testing Shared Examples
# This file provides clean, simple shared examples for testing controller infrastructure
# without the complexity of common.rb environment setup

RSpec.shared_examples "basic_megabar_controller" do
  describe "Basic Controller Structure" do
    it "can be instantiated" do
      expect(described_class.new).to be_a(described_class)
    end

    it "inherits from correct base class" do
      expected_base = if described_class.name.include?('Master') || described_class.name.include?('Root') || described_class.name.include?('Flat') || described_class.name.include?('ApplicationController')
                        ActionController::Base
                      else
                        MegaBar::ApplicationController
                      end
      expect(described_class.superclass).to eq(expected_base)
    end

    it "includes MegaBarConcern (if applicable)" do
      # Skip controllers that don't include MegaBarConcern
      skip_controllers = %w[
        ApplicationController MasterPagesController MasterLayoutsController MasterBlocksController 
        RootsController FlatsController
      ]
      
      controller_name = described_class.name.split('::').last
      
      if skip_controllers.include?(controller_name)
        expect(described_class.included_modules).not_to include(MegaBar::MegaBarConcern)
      else
        expect(described_class.included_modules).to include(MegaBar::MegaBarConcern)
      end
    end

    it "has proper controller setup" do
      # Just verify it's a controller class
      expect(described_class.ancestors).to include(ActionController::Base)
    end
  end
end

RSpec.shared_examples "megabar_controller_with_model" do |model_class_name|
  include_examples "basic_megabar_controller"
  
  describe "Model Association" do
    let(:expected_model_class) { "MegaBar::#{model_class_name}".constantize }
    
    it "has the expected model class available" do
      expect(expected_model_class).to be_a(Class)
      expect(expected_model_class.superclass).to eq(ActiveRecord::Base)
    end

    it "model supports basic ActiveRecord methods" do
      expect(expected_model_class.respond_to?(:where)).to be true
      expect(expected_model_class.respond_to?(:create!)).to be true
      expect(expected_model_class.respond_to?(:all)).to be true
    end

    it "model has expected table name" do
      expected_table = "mega_bar_#{model_class_name.underscore.pluralize}"
      expect(expected_model_class.table_name).to eq(expected_table)
    end
  end
end

RSpec.shared_examples "crud_controller" do |model_class_name|
  include_examples "megabar_controller_with_model", model_class_name
  
  describe "CRUD Methods" do
    it "responds to standard CRUD actions" do
      expect(described_class.instance_methods).to include(:index)
      expect(described_class.instance_methods).to include(:show)
      expect(described_class.instance_methods).to include(:new)
      expect(described_class.instance_methods).to include(:edit)
      expect(described_class.instance_methods).to include(:create)
      expect(described_class.instance_methods).to include(:update)
    end
  end
end

RSpec.shared_examples "special_controller" do
  include_examples "basic_megabar_controller"
  
  describe "Special Controller" do
    it "has expected base functionality" do
      expect(described_class).to be_a(Class)
      expect(described_class.superclass).to be_a(Class)
    end
  end
end 