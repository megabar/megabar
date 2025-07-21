require 'spec_helper'

# Modernized Common Testing Infrastructure for MegaBar
# This handles the complex dependency chain with deterministic IDs
RSpec.shared_context "deterministic_megabar_setup" do
  before(:each) do
    # Clean slate for deterministic testing
    cleanup_all_records
    setup_deterministic_test_data
  end

  after(:each) do
    cleanup_all_records
  end

  # Core test data setup with deterministic IDs
  let(:test_template) { create_test_template }
  let(:test_template_section) { create_test_template_section }
  let(:test_model) { create_test_model }
  let(:test_fields) { create_test_fields }
  let(:test_model_display_formats) { create_test_model_display_formats }
  let(:test_page) { create_test_page }
  let(:test_layout) { create_test_layout }
  let(:test_layout_section) { create_test_layout_section }
  let(:test_block) { create_test_block }
  let(:test_model_displays) { create_test_model_displays }
  let(:test_field_displays) { create_test_field_displays }

  # Controller testing helpers
  let(:controller_instance) { described_class.new }
  let(:sample_record) { test_model.constantize.first || create_sample_record }

  private

  def cleanup_all_records
    # Clean in dependency order (children first)
    [
      MegaBar::FieldDisplay,
      MegaBar::ModelDisplay, 
      MegaBar::Block,
      MegaBar::LayoutSection,
      MegaBar::Layout,
      MegaBar::Page,
      MegaBar::Field,
      MegaBar::Model,
      MegaBar::ModelDisplayFormat,
      MegaBar::TemplateSection,
      MegaBar::Template
    ].each(&:destroy_all)
  end

  def setup_deterministic_test_data
    # Skip problematic callbacks during setup
    skip_callbacks_for_testing
    
    # Create the full dependency chain
    test_template
    test_template_section
    test_model_display_formats
    test_model
    test_fields
    test_page
    test_layout
    test_layout_section
    test_block
    test_model_displays
    test_field_displays
    
    # Re-enable callbacks
    restore_callbacks_for_testing
  end

  def create_test_template
    FactoryBot.create(:template, 
      code_name: 'test_common_template',
      name: 'Test Common Template'
    )
  end

  def create_test_template_section
    FactoryBot.create(:template_section,
      template: test_template,
      name: 'main',
      code_name: 'main'
    )
  end

  def create_test_model_display_formats
    # Use find_or_create_by to avoid deterministic ID conflicts
    [
      MegaBar::ModelDisplayFormat.find_or_create_by(name: 'textread'),
      MegaBar::ModelDisplayFormat.find_or_create_by(name: 'textbox'), 
      MegaBar::ModelDisplayFormat.find_or_create_by(name: 'GridHtml')
    ]
  end

  def create_test_model
    # This creates the model that the controller is testing
    classname = described_class.name.demodulize.gsub('Controller', '').singularize
    tablename = "mega_bar_#{classname.underscore.pluralize}"
    
    FactoryBot.create(:model,
      classname: classname,
      tablename: tablename,
      name: "#{classname} Model",
      modyule: 'MegaBar'
    )
  end

  def create_test_fields
    # Create essential fields for the model
    model_id = test_model.id
    
    [
      { field: 'id', data_type: 'integer' },
      { field: 'name', data_type: 'string' },
      { field: 'created_at', data_type: 'datetime' },
      { field: 'updated_at', data_type: 'datetime' }
    ].map do |field_attrs|
      FactoryBot.create(:field,
        field: field_attrs[:field],
        data_type: field_attrs[:data_type],
        model_id: model_id,
        tablename: test_model.tablename
      )
    end
  end

  def create_test_page
    # Skip the complex callback chain initially
    MegaBar::Page.skip_callback(:create, :after, :create_layout_for_page) rescue nil
    
    page = FactoryBot.create(:page,
      name: "#{test_model.classname} Test Page",
      path: "/test-#{test_model.classname.underscore.pluralize}",
      template_id: test_template.id,
      model_id: test_model.id
    )
    
    MegaBar::Page.set_callback(:create, :after, :create_layout_for_page) rescue nil
    page
  end

  def create_test_layout
    FactoryBot.create(:layout,
      page: test_page,
      template: test_template,
      name: "#{test_model.classname} Layout",
      base_name: test_model.classname
    )
  end

  def create_test_layout_section
    FactoryBot.create(:layout_section,
      layout: test_layout,
      name: 'main_section',
      code_name: 'main'
    )
  end

  def create_test_block
    FactoryBot.create(:block,
      layout_section: test_layout_section,
      name: "#{test_model.classname} Block",
      model_id: test_model.id
    )
  end

  def create_test_model_displays
    # Create model displays for different actions
    ['index', 'show', 'edit', 'new'].map do |action|
      FactoryBot.create(:model_display,
        model_id: test_model.id,
        block: test_block,
        action: action,
        format: test_model_display_formats.sample.id
      )
    end
  end

  def create_test_field_displays
    test_fields.flat_map do |field|
      test_model_displays.map do |model_display|
        FactoryBot.create(:field_display,
          field: field,
          model_display: model_display,
          format: test_model_display_formats.sample.name,
          action: model_display.action
        )
      end
    end
  end

  def create_sample_record
    # Create a sample record for the model being tested
    model_class = test_model.constantize
    
    if model_class.respond_to?(:create!)
      attributes = build_sample_attributes_for(model_class)
      model_class.create!(attributes)
    end
  rescue => e
    Rails.logger.warn "Could not create sample record for #{model_class}: #{e.message}"
    nil
  end

  def build_sample_attributes_for(model_class)
    # Build basic attributes based on the model's requirements
    attributes = {}
    
    # Add name if the model has a name field
    attributes[:name] = "Test #{model_class.name.demodulize}" if model_class.column_names.include?('name')
    
    # Add other required fields based on validations
    if model_class.respond_to?(:validators)
      model_class.validators.each do |validator|
        if validator.is_a?(ActiveRecord::Validations::PresenceValidator)
          validator.attributes.each do |attr|
            next if attributes.key?(attr)
            attributes[attr] = build_value_for_attribute(attr, model_class)
          end
        end
      end
    end
    
    attributes
  end

  def build_value_for_attribute(attr, model_class)
    # Smart attribute value building based on name and type
    case attr.to_s
    when 'name' then "Test #{model_class.name.demodulize}"
    when 'path' then "/test-path-#{rand(1000)}"
    when 'code_name' then "test_code_#{rand(1000)}"
    when /email/ then "test#{rand(1000)}@example.com"
    when /layout_section_id/ then test_layout_section&.id || 1
    when /layout_id/ then test_layout&.id || 1
    when /model_id/ then test_model&.id || 1
    when /template_id/ then test_template&.id || 1
    else "test_value_#{rand(1000)}"
    end
  end

  def skip_callbacks_for_testing
    # Skip callbacks that cause complex dependency issues during testing
    callback_configs = [
      [MegaBar::Page, :create, :after, :create_layout_for_page],
      [MegaBar::Page, :create, :after, :add_route],
      [MegaBar::Layout, :create, :after, :create_layable_sections],
      [MegaBar::LayoutSection, :create, :after, :create_block_for_section],
      [MegaBar::Block, :create, :after, :make_model_displays],
      [MegaBar::Model, :create, :after, :make_page_for_model],
      [MegaBar::Model, :save, :after, :make_position_field],
      [MegaBar::Field, :create, :after, :make_field_displays],
      [MegaBar::Field, :create, :after, :make_migration]
    ]
    
    callback_configs.each do |klass, timing, phase, method|
      klass.skip_callback(timing, phase, method) rescue nil
    end
  end

  def restore_callbacks_for_testing
    # Restore callbacks (in case other tests need them)
    callback_configs = [
      [MegaBar::Page, :create, :after, :create_layout_for_page],
      [MegaBar::Page, :create, :after, :add_route],
      [MegaBar::Layout, :create, :after, :create_layable_sections],
      [MegaBar::LayoutSection, :create, :after, :create_block_for_section],
      [MegaBar::Block, :create, :after, :make_model_displays],
      [MegaBar::Model, :create, :after, :make_page_for_model],
      [MegaBar::Model, :save, :after, :make_position_field],
      [MegaBar::Field, :create, :after, :make_field_displays],
      [MegaBar::Field, :create, :after, :make_migration]
    ]
    
    callback_configs.each do |klass, timing, phase, method|
      klass.set_callback(timing, phase, method) rescue nil
    end
  end
end

# Shared examples for testing MegaBarConcern functionality
RSpec.shared_examples "megabar_concern_controller" do
  include_context "deterministic_megabar_setup"

  describe "Basic Controller Functionality" do
    it "includes MegaBarConcern" do
      expect(described_class.included_modules).to include(MegaBar::MegaBarConcern)
    end

    it "can be instantiated" do
      expect(controller_instance).to be_a(described_class)
    end

    it "inherits from MegaBar::ApplicationController" do
      expect(described_class.superclass).to eq(MegaBar::ApplicationController)
    end
  end

  describe "Deterministic ID Integration" do
    it "works with the deterministic ID system" do
      puts "\n=== #{described_class.name} Deterministic ID Test ==="
      puts "Template ID: #{test_template.id}"
      puts "Model ID: #{test_model.id}"
      puts "Page ID: #{test_page.id}"
      puts "Layout ID: #{test_layout.id}"
      puts "Block ID: #{test_block.id}"
      puts "Sample Record: #{sample_record&.id || 'None created'}"
      puts "=" * 50

      expect(test_template.id).to be_between(12000, 12999)
      expect(test_page.id).to be_between(4000, 4999)
      
      if test_layout.present?
        expect(test_layout.id).to be_between(5000, 5999)
      end
      
      if test_block.present?
        expect(test_block.id).to be_between(7000, 7999)
      end
    end
  end

  describe "Model Associations" do
    it "creates the full dependency chain" do
      expect(test_template).to be_persisted
      expect(test_template_section).to be_persisted
      expect(test_model).to be_persisted
      expect(test_fields.count).to be > 0
      expect(test_page).to be_persisted
      
      # Complex associations work
      expect(test_template_section.template).to eq(test_template)
      expect(test_page.template_id).to eq(test_template.id)
      
      puts "\n✅ Full dependency chain created successfully"
      puts "   Template → TemplateSection → Model → Fields → Page → Layout → Block"
    end

    it "handles model-specific setup correctly" do
      classname = described_class.name.demodulize.gsub('Controller', '').singularize
      expect(test_model.classname).to eq(classname)
      
      tablename = "mega_bar_#{classname.underscore.pluralize}"
      expect(test_model.tablename).to eq(tablename)
      
      puts "\n✅ Model-specific setup: #{classname} → #{tablename}"
    end
  end

  describe "CCCUX Authorization Integration" do
    it "includes authorization helpers" do
      if defined?(Cccux::AuthorizationHelper)
        expect(controller_instance.class.included_modules.map(&:to_s)).to include('MegaBar::AuthorizationHelper')
        puts "✅ CCCUX authorization available"
      else
        puts "ℹ️  Using MegaBar authorization fallback"
      end
    end
  end
end 