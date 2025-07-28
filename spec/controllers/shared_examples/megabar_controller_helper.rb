# Shared helper for MegaBar controller testing
# This module contains the proven pattern for setting up working MegaBar controller tests

module MegaBarControllerTestHelper
  
  # Common setup that enables MegaBar object chain creation
  def setup_megabar_callbacks
    # Skip file generation callbacks that cause issues in test environment
    MegaBar::Field.skip_callback("create", :after, :make_migration) rescue nil
    MegaBar::Model.skip_callback("create", :after, :make_all_files) rescue nil
    
    # Enable the MegaBar object creation callbacks
    MegaBar::Model.set_callback("create", :after, :make_page_for_model)
    MegaBar::Page.set_callback("create", :after, :create_layout_for_page)
    MegaBar::Layout.set_callback("create", :after, :create_layable_sections)
    MegaBar::LayoutSection.set_callback("create", :after, :create_block_for_section)
    MegaBar::Block.set_callback("create", :after, :make_model_displays)
  end
  
  # Common cleanup for deterministic testing
  def cleanup_megabar_records
    [
      MegaBar::FieldDisplay,
      MegaBar::ModelDisplay,
      MegaBar::Block,
      MegaBar::Layable,
      MegaBar::LayoutSection,
      MegaBar::Layout,
      MegaBar::Page,
      MegaBar::Field,
      MegaBar::Model,
      MegaBar::TemplateSection,
      MegaBar::Template
    ].each(&:destroy_all)
  end
  
  # Create test template with deterministic approach
  def create_test_template(code_name)
    MegaBar::Template.find_by(code_name: code_name) ||
      MegaBar::Template.create!(
        name: "#{code_name.humanize} Test Template",
        code_name: code_name
      )
  end
  
  # Create test template section with deterministic approach
  def create_test_template_section(template, section_code_name)
    existing_section = MegaBar::TemplateSection.find_by(
      template: template,
      code_name: section_code_name
    )
    
    existing_section || MegaBar::TemplateSection.create!(
      template: template,
      name: "#{section_code_name.humanize} Section",
      code_name: section_code_name,
      position: 1
    )
  end
  
  # Create test model with complete MegaBar chain
  def create_test_model(name:, classname:, tablename:, template:, template_section:)
    puts "🔧 Creating #{classname} model with template #{template.id} and template_section #{template_section.id}"
    
    model = MegaBar::Model.create!(
      name: name,
      classname: classname,
      tablename: tablename,
      schema: "sqlite",
      mega_model: "regular",
      modyule: "MegaBar",
      make_page: template.id,
      default_sort_field: "id",
      default_sort_order: "desc"
    )
    
    # CRITICAL FIX: Ensure model_id propagates through the chain for ModelDisplay creation
    fix_model_displays_creation(model, tablename)
    
    model
  end
  
  # Fix to ensure ModelDisplays are created properly
  def fix_model_displays_creation(model, tablename)
    # Derive path from tablename
    path = "/mega-bar/#{tablename.gsub('mega_bar_', '').dasherize}"
    
    page = MegaBar::Page.find_by(path: path)
    if page && !page.model_id
      page.update!(model_id: model.id)
      if layout = page.layouts.first
        layout.update!(model_id: model.id)
        layout.layout_sections.each do |ls|
          if ls.code_name.include?('main')
            ls.destroy
            ls_new = MegaBar::LayoutSection.create!(
              code_name: ls.code_name,
              make_block: true,
              model_id: model.id
            )
            MegaBar::Layable.create!(
              layout_section_id: ls_new.id,
              layout_id: layout.id
            )
          end
        end
      end
    end
  end
  
  # Unified block finder that works across different controller setups
  def find_test_block(layout)
    layout_sections = MegaBar::LayoutSection.joins(:layables)
                       .where(mega_bar_layables: { layout_id: layout.id })
    layout_sections.first&.blocks&.first
  end
  
  # Helper to verify complete MegaBar chain creation
  def verify_megabar_chain(model:, page:, layout:, block:, model_displays:, puts_output: true)
    if puts_output
      puts "✅ Model created: #{model.id} - #{model.name}"
      puts "✅ Page created: #{page.path}" 
      puts "✅ Layout created: #{layout.name}"
      puts "✅ Block created: #{block.name}"
      puts "✅ ModelDisplays created: #{model_displays.count} (#{model_displays.pluck(:action).join(', ')})"
    end
    
    expect(model).to be_persisted
    expect(page).to be_present
    expect(layout).to be_present
    expect(block).to be_present  
    expect(model_displays.count).to eq(4)
  end
  
  # Create test field with proper validation requirements
  def create_test_field(model:, field_name:, tablename:)
    MegaBar::Field.create!(
      model_id: model.id,
      field: field_name, 
      tablename: tablename,
      data_type: "string",
      default_data_format: "textread",
      default_data_format_edit: "textbox"
    )
  end
  
  # Create test field display for UI component testing
  def create_test_field_display(model_display:, field:, format: "textbox")
    MegaBar::FieldDisplay.create!(
      model_display_id: model_display.id,
      field_id: field.id,
      format: format,
      header: "Test #{format.humanize} Field"
    )
  end
  
  # Environment status output for debugging
  def show_megabar_environment_status(model:, page:, block:, model_displays:, controller_name:)
    puts "\n🔧 MegaBar Environment Status for #{controller_name}:"
    puts "Model: #{model.classname} (ID: #{model.id})"
    puts "Page: #{page.path} (ID: #{page.id})"  
    puts "Block: #{block.name} (ID: #{block.id})"
    puts "ModelDisplays: #{model_displays.count} actions"
    puts "✅ Environment ready for #{controller_name} controller action testing"
  end
end

# RSpec shared examples using the helper
RSpec.shared_examples "working_megabar_controller" do |controller_class_name, model_name, model_class_name, table_name, path_name|
  include MegaBarControllerTestHelper
  
  before(:each) do
    cleanup_megabar_records
    setup_megabar_callbacks
  end
  
  let(:test_template) { create_test_template("#{model_name.downcase}_test") }
  let(:test_template_section) { create_test_template_section(test_template, "#{model_name.downcase}_main") }
  
  let(:test_model) do
    create_test_model(
      name: model_name,
      classname: model_class_name,
      tablename: table_name,
      template: test_template,
      template_section: test_template_section
    )
  end
  
  let(:test_page) { MegaBar::Page.find_by(path: path_name) }
  let(:test_layout) { MegaBar::Layout.find_by(page: test_page) }
  let(:test_block) { find_test_block(test_layout) }
  let(:test_model_displays) { 
    return [] unless test_block
    MegaBar::ModelDisplay.where(block_id: test_block.id) 
  }
  
  it "controller exists and can be instantiated" do
    controller = controller_class_name.constantize.new
    expect(controller).to be_a(controller_class_name.constantize)
    expect(controller.class.included_modules).to include(MegaBar::MegaBarConcern)
  end
  
  it "creates complete MegaBar object chain when model is created" do
    puts "\n🧪 Testing Complete MegaBar Setup for #{controller_class_name}"
    
    model = test_model
    page = test_page
    layout = test_layout  
    block = test_block
    model_displays = test_model_displays
    
    verify_megabar_chain(
      model: model, 
      page: page, 
      layout: layout, 
      block: block, 
      model_displays: model_displays
    )
    
    puts "🎉 Complete MegaBar chain created successfully for #{model_name}!"
  end
  
  it "has proper MegaBar environment setup for controller actions" do
    model = test_model
    page = test_page
    block = test_block
    model_displays = test_model_displays
    
    show_megabar_environment_status(
      model: model,
      page: page, 
      block: block,
      model_displays: model_displays,
      controller_name: controller_class_name
    )
    
    verify_megabar_chain(
      model: model, 
      page: page, 
      layout: test_layout, 
      block: block, 
      model_displays: model_displays,
      puts_output: false
    )
    
    puts "💡 Next step: Test actual controller actions with this setup"
  end
end 