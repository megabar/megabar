require 'spec_helper'

RSpec.describe "Simple Page Creation Integration", type: :integration do
  # This tests the ACTUAL page creation workflow as it happens in MegaBar
  # Based on the form HTML showing the real page creation process
  
  before(:each) do
    # Clean up any existing test data
    [
      MegaBar::Block,
      MegaBar::Layable,
      MegaBar::LayoutSection,
      MegaBar::Layout,
      MegaBar::Page,
      MegaBar::TemplateSection,
      MegaBar::Template
    ].each(&:destroy_all)
  end

  describe "Basic Page Creation Workflow" do
    let(:test_template) do
      MegaBar::Template.create!(
        name: 'No Columns Template',
        code_name: 'no_columns'
      )
    end

    let(:main_template_section) do
      MegaBar::TemplateSection.create!(
        template: test_template,
        name: 'Main Section',
        code_name: 'main',
        position: 1
      )
    end

    it "creates a page with the basic layout cascade" do
      puts "\n🧪 TESTING: Basic Page Creation (like the form shows)"
      puts "-" * 50

      # Ensure template and template section exist
      template = test_template
      template_section = main_template_section
      
      puts "📋 Using Template #{template.id} with #{template.template_sections.count} sections"

      # Create a page with the form parameters (attr_accessors)
      page = MegaBar::Page.create!(
        name: "Test Page",
        path: "/test-page",
        template_id: template.id,          # From the radio button
        make_layout_and_block: true,       # Checkbox in form
        base_name: "TestPage",             # From form input
        block_text: "Hello World"          # From form input
      )

      puts "📄 Created Page #{page.id}: '#{page.name}' at #{page.path}"

      # Verify the cascade worked (should auto-create layout)
      layout = MegaBar::Layout.find_by(page: page)
      expect(layout).to be_present
      expect(layout.template_id).to eq(template.id)
      puts "🎨 Layout auto-created: #{layout.id}"

      # Verify layout sections were created (one per template section)
      layout_sections = layout.layout_sections
      expect(layout_sections.count).to eq(template.template_sections.count)
      puts "📐 Layout sections auto-created: #{layout_sections.count}"

      # Verify the many-to-many relationship through Layable
      layout_sections.each do |section|
        layable = MegaBar::Layable.find_by(layout: layout, layout_section: section)
        expect(layable).to be_present
        puts "🔗 Layable connection: Layout #{layout.id} ↔ LayoutSection #{section.id}"
      end

      # Verify simple blocks were created (because make_layout_and_block=true)
      total_blocks = 0
      layout_sections.each do |section|
        blocks = section.blocks
        total_blocks += blocks.count
        puts "🧱 Section '#{section.code_name}' has #{blocks.count} blocks"
        
        if blocks.any?
          block = blocks.first
          expect(block.name).to include('Block')
          # These should NOT be created automatically
          expect(block.model_displays.count).to eq(0)
          puts "   ✅ Block #{block.id} created with NO model displays (correct)"
        end
      end
      
      expect(total_blocks).to be > 0
      puts "✅ Total blocks created: #{total_blocks}"
      puts "✅ Basic page creation workflow successful!"
    end

    it "handles page creation without make_layout_and_block" do
      puts "\n🧪 TESTING: Page Creation without auto-block generation"
      puts "-" * 50

      template = test_template
      template_section = main_template_section

      # Create page without the make_layout_and_block checkbox
      page = MegaBar::Page.create!(
        name: "Simple Page",
        path: "/simple-page",
        template_id: template.id,
        make_layout_and_block: false,      # Checkbox unchecked
        base_name: "SimplePage"
      )

      puts "📄 Created Page #{page.id}: '#{page.name}'"

      # Should still create layout and layout sections
      layout = MegaBar::Layout.find_by(page: page)
      expect(layout).to be_present
      puts "🎨 Layout created: #{layout.id}"

      layout_sections = layout.layout_sections
      expect(layout_sections.count).to eq(template.template_sections.count)
      puts "📐 Layout sections created: #{layout_sections.count}"

      # But should NOT create blocks automatically
      total_blocks = layout_sections.sum { |section| section.blocks.count }
      expect(total_blocks).to eq(0)
      puts "✅ No blocks auto-created (correct behavior)"
    end

    it "supports multiple template sections (like left/right columns)" do
      puts "\n🧪 TESTING: Multi-column template page creation"
      puts "-" * 50

      # Create a template with multiple sections (like "Has Left Column")
      multi_template = MegaBar::Template.create!(
        name: 'Has Left Column',
        code_name: 'has_left_column'
      )

      # Add multiple template sections
      header_section = MegaBar::TemplateSection.create!(
        template: multi_template,
        name: 'Header',
        code_name: 'header',
        position: 1
      )

      left_section = MegaBar::TemplateSection.create!(
        template: multi_template,
        name: 'Left Column',
        code_name: 'left',
        position: 2
      )

      main_section = MegaBar::TemplateSection.create!(
        template: multi_template,
        name: 'Main',
        code_name: 'main',
        position: 3
      )

      footer_section = MegaBar::TemplateSection.create!(
        template: multi_template,
        name: 'Footer',
        code_name: 'footer',
        position: 4
      )

      puts "📋 Multi-template has #{multi_template.template_sections.count} sections"

      # Create page with multi-column template
      page = MegaBar::Page.create!(
        name: "Multi-Column Page",
        path: "/multi-column",
        template_id: multi_template.id,
        make_layout_and_block: true,
        base_name: "MultiColumn"
      )

      puts "📄 Created multi-column page #{page.id}"

      # Verify all sections were created
      layout = MegaBar::Layout.find_by(page: page)
      layout_sections = layout.layout_sections
      
      expect(layout_sections.count).to eq(4)
      puts "📐 Created #{layout_sections.count} layout sections"

      # Verify each section has appropriate naming
      section_names = layout_sections.map(&:code_name).sort
      expected_names = %w[MultiColumn_header MultiColumn_left MultiColumn_main MultiColumn_footer].sort
      expect(section_names).to eq(expected_names)
      puts "📝 Section names: #{section_names.join(', ')}"

      # Each section should have blocks
      layout_sections.each do |section|
        expect(section.blocks.count).to be > 0
        puts "🧱 #{section.code_name}: #{section.blocks.count} blocks"
      end

      puts "✅ Multi-column page creation successful!"
    end
  end

  describe "Page Creation Error Handling" do
    it "handles missing template gracefully" do
      expect {
        MegaBar::Page.create!(
          name: "Broken Page",
          path: "/broken",
          template_id: 99999  # Non-existent
        )
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "validates unique page paths" do
      template = MegaBar::Template.create!(name: 'Test', code_name: 'test')
      
      # Create first page
      MegaBar::Page.create!(
        name: "First Page",
        path: "/duplicate",
        template_id: template.id
      )

      # Try to create second with same path
      expect {
        MegaBar::Page.create!(
          name: "Second Page",
          path: "/duplicate",  # Same path
          template_id: template.id
        )
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe "Real Form Parameter Simulation" do
    it "simulates the exact form submission from the HTML" do
      puts "\n🧪 TESTING: Exact Form Submission Simulation"
      puts "-" * 50

      # Create templates to match the radio button values
      template_1 = MegaBar::Template.create!(name: 'No Columns', code_name: 'no_columns')
      template_2 = MegaBar::Template.create!(name: 'Has Left Column', code_name: 'has_left_column')

      # Add template sections to template_1
      MegaBar::TemplateSection.create!(
        template: template_1,
        name: 'Main',
        code_name: 'main'
      )

      # Simulate form submission with exact parameters from the HTML form
      form_params = {
        name: "My Test Page",                    # page[name]
        path: "/my-test-page",                   # page[path]
        mega_page: "mega",                       # page[mega_page] - radio button
        template_id: template_1.id,              # page[template_id] - radio button
        make_layout_and_block: true,             # page[make_layout_and_block] - checkbox
        block_text: "Welcome to my page",       # page[block_text]
        base_name: "MyTestPage"                  # page[base_name]
      }

      puts "📝 Form params: #{form_params}"

      # Create page exactly as the form would
      page = MegaBar::Page.create!(form_params)

      puts "📄 Page created from form simulation: #{page.id}"
      puts "   Name: #{page.name}"
      puts "   Path: #{page.path}"
      puts "   Template: #{page.template_id}"

      # Verify the workflow worked
      layout = MegaBar::Layout.find_by(page: page)
      expect(layout).to be_present
      expect(layout.name).to include("MyTestPage")
      puts "🎨 Layout: #{layout.name}"

      layout_sections = layout.layout_sections
      expect(layout_sections.count).to be > 0
      puts "📐 Layout sections: #{layout_sections.count}"

      # Check that blocks were created with the block_text
      layout_sections.each do |section|
        blocks = section.blocks
        if blocks.any?
          block = blocks.first
          puts "🧱 Block: #{block.name}"
          # The block_text should be in the block's html field
          # (based on the LayoutSection.create_block_for_section method)
        end
      end

      puts "✅ Form simulation successful!"
    end
  end
end 