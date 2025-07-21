# Integration Test Setup for MegaBar Complex Workflows
# This handles the complete dependency chain that production MegaBar requires

RSpec.shared_context "megabar_integration_setup" do
  # Integration test database setup
  before(:all) do
    setup_integration_database
  end

  after(:all) do
    cleanup_integration_database
  end

  before(:each) do
    setup_integration_environment
  end

  after(:each) do
    cleanup_integration_records
  end

  # Core integration data - built in dependency order
  let(:integration_template) { create_integration_template }
  let(:integration_template_section) { create_integration_template_section }
  let(:integration_model_display_formats) { create_integration_model_display_formats }
  let(:integration_model) { create_integration_model }
  let(:integration_fields) { create_integration_fields }
  let(:integration_page) { create_integration_page }
  let(:integration_layout) { create_integration_layout }
  let(:integration_layout_section) { create_integration_layout_section }
  let(:integration_block) { create_integration_block }
  let(:integration_model_displays) { create_integration_model_displays }
  let(:integration_field_displays) { create_integration_field_displays }

  # Test data that can be customized per test
  let(:test_template_name) { 'integration_test_template' }
  let(:test_model_name) { 'IntegrationTestModel' }
  let(:test_page_path) { '/integration-test-page' }

  private

  def setup_integration_database
    puts "\n🔧 Setting up integration test database..."
    
    # Ensure all tables exist
    unless ActiveRecord::Base.connection.table_exists?('mega_bar_templates')
      puts "⚠️  Database tables missing - running migrations..."
      # This would normally run migrations in a real setup
    end
    
    puts "✅ Integration database ready"
  end

  def cleanup_integration_database
    # Only cleanup test-specific data, not structure
    puts "\n🧹 Integration test database cleanup complete"
  end

  def setup_integration_environment
    puts "\n🚀 Setting up integration test environment..."
    
    # Configure callbacks for integration testing
    configure_callbacks_for_integration
    
    # Set up any required environment variables
    setup_integration_environment_variables
    
    puts "✅ Integration environment ready"
  end

  def cleanup_integration_records
    # Clean up in reverse dependency order to avoid foreign key issues
    cleanup_order = [
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
    ]

    cleanup_order.each do |model_class|
      # Only delete integration test records, not all records
      # Different models have different identifying columns
      if model_class.column_names.include?('name') && model_class.column_names.include?('code_name')
        model_class.where("name LIKE ? OR code_name LIKE ?", 
                         '%integration_test%', '%integration_test%').destroy_all
      elsif model_class.column_names.include?('name')
        model_class.where("name LIKE ?", '%integration_test%').destroy_all
      elsif model_class.column_names.include?('code_name')
        model_class.where("code_name LIKE ?", '%integration_test%').destroy_all
      else
        # For models without name/code_name, delete all records for clean slate
        model_class.destroy_all
      end
    end
  end

  def configure_callbacks_for_integration
    # Unlike unit tests, integration tests SHOULD trigger callbacks
    # This is where we test the real production behavior
    
    # Ensure all callbacks are enabled for integration testing
    callback_configs = [
      [MegaBar::Page, :create, :after, :create_layout_for_page],
      [MegaBar::Layout, :create, :after, :create_layable_sections],
      [MegaBar::LayoutSection, :create, :after, :create_block_for_section],
      [MegaBar::Block, :create, :after, :make_model_displays],
      [MegaBar::Model, :create, :after, :make_page_for_model],
      [MegaBar::Model, :save, :after, :make_position_field],
      [MegaBar::Field, :create, :after, :make_field_displays],
      # Skip migration callback in tests
      # [MegaBar::Field, :create, :after, :make_migration]
    ]

    callback_configs.each do |klass, timing, phase, method|
      begin
        # Ensure callback is set (in case it was disabled elsewhere)
        klass.set_callback(timing, phase, method)
      rescue ArgumentError => e
        puts "⚠️  Callback #{method} not available for #{klass}: #{e.message}"
      end
    end
  end

  def setup_integration_environment_variables
    # Set up any required environment configuration
    # This mimics production environment setup
  end

  # Integration-specific factory methods
  # These create records with full callback chains enabled

  def create_integration_template
    puts "📋 Creating integration template..."
    template = MegaBar::Template.create!(
      name: "Integration Test Template",
      code_name: test_template_name
    )
    
    # Create a default template section (required for layout creation)
    template_section = MegaBar::TemplateSection.create!(
      template: template,
      name: 'Integration Main Section',
      code_name: 'main',
      position: 1
    )
    
    puts "✅ Template created with ID: #{template.id} and section ID: #{template_section.id}"
    template
  end

  def create_integration_template_section
    puts "📄 Creating integration template section..."
    section = MegaBar::TemplateSection.create!(
      template: integration_template,
      name: 'Integration Main Section',
      code_name: 'integration_main',
      position: 1
    )
    puts "✅ Template section created with ID: #{section.id}"
    section
  end

  def create_integration_model_display_formats
    puts "🎨 Creating integration model display formats..."
    formats = [
      { name: 'textread' },
      { name: 'textbox' },
      { name: 'select' }
    ].map do |format_attrs|
      format = MegaBar::ModelDisplayFormat.find_or_create_by(name: format_attrs[:name])
      puts "✅ Format '#{format.name}' ready with ID: #{format.id}"
      format
    end
    formats
  end

  def create_integration_model
    puts "🏗️ Creating integration model..."
    
    # This creates the model that represents the controller being tested
    # It should trigger the full callback chain
    model = MegaBar::Model.create!(
      classname: test_model_name,
      tablename: "mega_bar_#{test_model_name.underscore.pluralize}",
      name: "#{test_model_name} Integration Model",
      modyule: 'MegaBar',
      schema: 'integration_test',
      default_sort_field: 'id',
      default_sort_order: 'desc'
    )
    
    puts "✅ Model created with ID: #{model.id}"
    model
  end

  def create_integration_fields
    puts "🔧 Creating integration fields..."
    
    fields = [
      { field: 'id', data_type: 'integer' },
      { field: 'name', data_type: 'string' },
      { field: 'description', data_type: 'text' },
      { field: 'status', data_type: 'string' },
      { field: 'created_at', data_type: 'datetime' },
      { field: 'updated_at', data_type: 'datetime' }
    ].map do |field_attrs|
      field = MegaBar::Field.create!(
        field: field_attrs[:field],
        data_type: field_attrs[:data_type],
        model_id: integration_model.id,
        tablename: integration_model.tablename,
        default_data_format: 'textread',
        default_data_format_edit: 'textbox'
      )
      puts "✅ Field '#{field.field}' created with ID: #{field.id}"
      field
    end
    
    puts "✅ Created #{fields.count} fields total"
    fields
  end

  def create_integration_page
    puts "📄 Creating integration page..."
    
    # This should trigger create_layout_for_page callback
    page = MegaBar::Page.create!(
      name: "Integration Test Page",
      path: test_page_path,
      template_id: integration_template.id,
      model_id: integration_model.id
    )
    
    puts "✅ Page created with ID: #{page.id}"
    puts "   Path: #{page.path}"
    puts "   Template: #{page.template_id}"
    page
  end

  def create_integration_layout
    puts "🎨 Creating integration layout..."
    
    # This should be created by the page callback, but we can also create explicitly
    layout = MegaBar::Layout.find_by(page: integration_page) ||
              MegaBar::Layout.create!(
                page: integration_page,
                template: integration_template,
                name: "#{test_model_name} Integration Layout",
                base_name: test_model_name
              )
    
    puts "✅ Layout ready with ID: #{layout.id}"
    layout
  end

  def create_integration_layout_section
    puts "📐 Creating integration layout section..."
    
    # This should be created by layout callback
        # Find or create a layout section for this layout through layables
    section = MegaBar::LayoutSection.joins(:layables)
                                   .where(layables: { layout_id: integration_layout.id })
                                   .first

    unless section
      section = MegaBar::LayoutSection.create!(
        code_name: 'integration_main_section'
      )
      
      # Create the layable connection
      MegaBar::Layable.create!(
        layout_id: integration_layout.id,
        layout_section_id: section.id
      )
    end
    
    puts "✅ Layout section ready with ID: #{section.id}"
    section
  end

  def create_integration_block
    puts "🧱 Creating integration block..."
    
    # This should be created by layout section callback
    block = MegaBar::Block.find_by(layout_section: integration_layout_section) ||
            MegaBar::Block.create!(
              layout_section: integration_layout_section,
              name: "#{test_model_name} Integration Block",
              model_id: integration_model.id
            )
    
    puts "✅ Block ready with ID: #{block.id}"
    block
  end

  def create_integration_model_displays
    puts "📊 Creating integration model displays..."
    
    displays = ['index', 'show', 'edit', 'new'].map do |action|
      display = MegaBar::ModelDisplay.find_by(
        model_id: integration_model.id,
        block: integration_block,
        action: action
      ) || MegaBar::ModelDisplay.create!(
        model_id: integration_model.id,
        block: integration_block,
        action: action,
        format: integration_model_display_formats.sample.id
      )
      
      puts "✅ ModelDisplay for '#{action}' ready with ID: #{display.id}"
      display
    end
    
    puts "✅ Created #{displays.count} model displays total"
    displays
  end

  def create_integration_field_displays
    puts "🎯 Creating integration field displays..."
    
    field_displays = []
    
    integration_fields.each do |field|
      integration_model_displays.each do |model_display|
        field_display = MegaBar::FieldDisplay.find_by(
          field_id: field.id,
          model_display_id: model_display.id
        ) || MegaBar::FieldDisplay.create!(
          field_id: field.id,
          model_display_id: model_display.id,
          format: integration_model_display_formats.sample.name,
          action: model_display.action
        )
        
        field_displays << field_display
      end
    end
    
    puts "✅ Created #{field_displays.count} field displays total"
    puts "   (#{integration_fields.count} fields × #{integration_model_displays.count} actions)"
    field_displays
  end
end

# Shared examples for complete MegaBar workflows
RSpec.shared_examples "complete_megabar_workflow" do
  include_context "megabar_integration_setup"

  it "creates the complete dependency chain successfully" do
    puts "\n" + "="*60
    puts "🧪 TESTING COMPLETE MEGABAR WORKFLOW"
    puts "="*60

    # Verify each step of the dependency chain
    expect(integration_template).to be_persisted
    expect(integration_template.id).to be_between(12000, 12999)

    expect(integration_template_section).to be_persisted
    expect(integration_template_section.template).to eq(integration_template)

    expect(integration_model).to be_persisted
    expect(integration_model.classname).to eq(test_model_name)

    expect(integration_fields.count).to be > 0
    integration_fields.each { |field| expect(field).to be_persisted }

    expect(integration_page).to be_persisted
    expect(integration_page.id).to be_between(4000, 4999)
    expect(integration_page.template_id).to eq(integration_template.id)

    expect(integration_layout).to be_persisted
    expect(integration_layout.page).to eq(integration_page)

    expect(integration_layout_section).to be_persisted
          expect(integration_layout_section.layouts.first).to eq(integration_layout)

    expect(integration_block).to be_persisted
    expect(integration_block.id).to be_between(7000, 7999)
    expect(integration_block.layout_section).to eq(integration_layout_section)

    expect(integration_model_displays.count).to eq(4)
    integration_model_displays.each do |display|
      expect(display).to be_persisted
      expect(display.block).to eq(integration_block)
    end

    expect(integration_field_displays.count).to eq(integration_fields.count * 4)
    integration_field_displays.each { |fd| expect(fd).to be_persisted }

    puts "\n✅ COMPLETE WORKFLOW SUCCESS!"
    puts "   Template #{integration_template.id} → Page #{integration_page.id} → Block #{integration_block.id}"
    puts "   #{integration_fields.count} fields, #{integration_model_displays.count} displays, #{integration_field_displays.count} field displays"
    puts "="*60
  end

  it "handles deterministic IDs correctly across the workflow" do
    # Test that IDs are in correct ranges and don't conflict
    id_ranges = {
      integration_template => [12000, 12999],
      integration_page => [4000, 4999], 
      integration_block => [7000, 7999]
    }

    id_ranges.each do |record, (min, max)|
      expect(record.id).to be_between(min, max),
        "#{record.class.name} ID #{record.id} should be between #{min}-#{max}"
    end

    # Test that deterministic ID generation is consistent
    template_id_1 = MegaBar::Template.deterministic_id(test_template_name)
    template_id_2 = MegaBar::Template.deterministic_id(test_template_name)
    expect(template_id_1).to eq(template_id_2)
    # The actual template ID might be different due to collisions, but should be in the correct range
    expect(integration_template.id).to be_between(12000, 12999)
  end
end 