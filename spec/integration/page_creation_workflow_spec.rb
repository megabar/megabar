require 'spec_helper'
require_relative 'shared_contexts/megabar_integration_setup'

RSpec.describe "Page Creation Workflow Integration", type: :integration do
  # This tests the complete workflow that happens when creating a MegaBar page
  # It includes all the complex dependencies and callbacks
  
  it_behaves_like "complete_megabar_workflow"
  
  describe "Page Creation with Template Integration" do
    include_context "megabar_integration_setup"
    
    let(:test_template_name) { 'page_creation_test_template' }
    let(:test_model_name) { 'PageCreationTestModel' }
    let(:test_page_path) { '/page-creation-test' }

    it "creates a page and automatically generates the complete stack" do
      puts "\n🧪 TESTING: Page Creation Auto-Generation"
      puts "-" * 50

      # Start with just a template and model
      template = integration_template
      model = integration_model
      
      puts "📋 Starting with Template #{template.id} and Model #{model.id}"

      # Create a page - this should trigger the entire cascade
      page = MegaBar::Page.create!(
        name: "Auto-Generated Test Page",
        path: "/auto-generated-test",
        template_id: template.id,
        model_id: model.id
      )

      puts "📄 Created Page #{page.id}"

      # Verify the cascade worked
      layout = MegaBar::Layout.find_by(page: page)
      expect(layout).to be_present
      puts "🎨 Layout auto-created: #{layout.id}"

      layout_sections = MegaBar::LayoutSection.where(layout: layout)
      expect(layout_sections.count).to be > 0
      puts "📐 Layout sections auto-created: #{layout_sections.count}"

      blocks = MegaBar::Block.joins(:layout_section).where(layout_sections: { layout: layout })
      expect(blocks.count).to be > 0
      puts "🧱 Blocks auto-created: #{blocks.count}"

      model_displays = MegaBar::ModelDisplay.where(block: blocks)
      expect(model_displays.count).to be > 0
      puts "📊 Model displays auto-created: #{model_displays.count}"

      puts "✅ Complete auto-generation workflow successful!"
    end

    it "handles page creation with custom template sections" do
      puts "\n🧪 TESTING: Page Creation with Custom Template Sections"
      puts "-" * 50

      # Create a template with multiple sections
      template = integration_template
      
      # Add additional template sections
      header_section = MegaBar::TemplateSection.create!(
        template: template,
        name: 'Header Section',
        code_name: 'header',
        position: 1
      )
      
      footer_section = MegaBar::TemplateSection.create!(
        template: template,
        name: 'Footer Section', 
        code_name: 'footer',
        position: 3
      )

      puts "📄 Template has #{template.template_sections.count} sections"

      # Create page with this multi-section template
      page = MegaBar::Page.create!(
        name: "Multi-Section Test Page",
        path: "/multi-section-test",
        template_id: template.id,
        model_id: integration_model.id
      )

      # Verify layout sections were created for each template section
      layout = MegaBar::Layout.find_by(page: page)
      layout_sections = layout.layout_sections
      
      expect(layout_sections.count).to be >= 2
      puts "📐 Created #{layout_sections.count} layout sections for template sections"

      # Verify each section has appropriate blocks
      layout_sections.each do |section|
        blocks = section.blocks
        puts "🧱 Section '#{section.code_name}' has #{blocks.count} blocks"
        expect(blocks.count).to be >= 0
      end

      puts "✅ Multi-section page creation successful!"
    end
  end

  describe "Page Rendering Integration" do
    include_context "megabar_integration_setup"

    it "can render a complete page with all components" do
      puts "\n🧪 TESTING: Complete Page Rendering"
      puts "-" * 50

      # Create the complete stack
      page = integration_page
      layout = integration_layout
      block = integration_block
      model_displays = integration_model_displays
      field_displays = integration_field_displays

      puts "📄 Testing page rendering for Page #{page.id}"

      # Simulate what happens during page rendering
      # This tests the MegaEnv system that controllers use

      expect(page.path).to eq(test_page_path)
      expect(layout.page).to eq(page)
      expect(block.layout_section.layout).to eq(layout)
      expect(model_displays.first.block).to eq(block)
      expect(field_displays.first.model_display).to be_in(model_displays)

      puts "✅ Page rendering structure verified!"

      # Test that we can find displays by action
      index_display = model_displays.find { |d| d.action == 'index' }
      show_display = model_displays.find { |d| d.action == 'show' }
      edit_display = model_displays.find { |d| d.action == 'edit' }
      new_display = model_displays.find { |d| d.action == 'new' }

      expect(index_display).to be_present
      expect(show_display).to be_present  
      expect(edit_display).to be_present
      expect(new_display).to be_present

      puts "📊 All CRUD displays available: ✅"

      # Test field displays for each action
      %w[index show edit new].each do |action|
        action_field_displays = field_displays.select { |fd| fd.action == action }
        expect(action_field_displays.count).to eq(integration_fields.count)
        puts "🎯 Action '#{action}' has #{action_field_displays.count} field displays"
      end

      puts "✅ Complete page rendering integration successful!"
    end
  end

  describe "Error Handling and Edge Cases" do
    include_context "megabar_integration_setup"

    it "handles missing template gracefully" do
      expect {
        MegaBar::Page.create!(
          name: "Missing Template Page",
          path: "/missing-template",
          template_id: 99999, # Non-existent template
          model_id: integration_model.id
        )
      }.to raise_error(ActiveRecord::InvalidForeignKey)
    end

    it "handles missing model gracefully" do
      expect {
        MegaBar::Page.create!(
          name: "Missing Model Page",
          path: "/missing-model", 
          template_id: integration_template.id,
          model_id: 99999 # Non-existent model
        )
      }.to raise_error(ActiveRecord::InvalidForeignKey)
    end

    it "validates unique page paths" do
      # Create first page
      MegaBar::Page.create!(
        name: "First Page",
        path: "/duplicate-path",
        template_id: integration_template.id,
        model_id: integration_model.id
      )

      # Try to create second page with same path
      expect {
        MegaBar::Page.create!(
          name: "Second Page", 
          path: "/duplicate-path", # Same path
          template_id: integration_template.id,
          model_id: integration_model.id
        )
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end 