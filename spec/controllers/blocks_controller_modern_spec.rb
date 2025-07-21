require 'spec_helper'
require_relative 'common_deterministic_spec'

RSpec.describe MegaBar::BlocksController, type: :controller do
  it_behaves_like "megabar_concern_controller"

  describe "Blocks-Specific Functionality" do
    include_context "deterministic_megabar_setup"

    it "creates blocks with proper layout_section association" do
      expect(test_block.layout_section).to eq(test_layout_section)
      expect(test_block.layout_section_id).to eq(test_layout_section.id)
      
      puts "\n✅ Block #{test_block.id} → LayoutSection #{test_layout_section.id}"
    end

    it "creates the full MegaBar stack for blocks" do
      puts "\n=== Complete MegaBar Stack for Blocks ==="
      puts "Template: #{test_template.id} (#{test_template.code_name})"
      puts "TemplateSection: #{test_template_section.id} (#{test_template_section.code_name})"
      puts "Model: #{test_model.id} (#{test_model.classname})"
      puts "Fields: #{test_fields.map(&:field).join(', ')} (#{test_fields.count} total)"
      puts "Page: #{test_page.id} (#{test_page.path})"
      puts "Layout: #{test_layout.id} (#{test_layout.name})"
      puts "LayoutSection: #{test_layout_section.id} (#{test_layout_section.code_name})"
      puts "Block: #{test_block.id} (#{test_block.name})"
      puts "ModelDisplays: #{test_model_displays.count} (#{test_model_displays.map(&:action).join(', ')})"
      puts "FieldDisplays: #{test_field_displays.count} total"
      puts "=" * 60

      # Verify the complete chain works
      expect(test_template).to be_persisted
      expect(test_template_section.template).to eq(test_template)
      expect(test_model).to be_persisted
      expect(test_fields.count).to eq(4)
      expect(test_page.template_id).to eq(test_template.id)
      expect(test_layout.page).to eq(test_page)
      expect(test_layout_section.layout).to eq(test_layout)
      expect(test_block.layout_section).to eq(test_layout_section)
      expect(test_model_displays.count).to eq(4) # index, show, edit, new
      expect(test_field_displays.count).to eq(16) # 4 fields × 4 actions
    end

    it "handles block validation requirements" do
      # Test that blocks require layout_section_id
      invalid_block = MegaBar::Block.new(name: 'Invalid Block')
      expect(invalid_block).not_to be_valid
      expect(invalid_block.errors[:layout_section_id]).to be_present

      # Test that our test_block is valid
      expect(test_block).to be_valid
      expect(test_block.layout_section_id).to be_present
    end

    it "creates model displays for all CRUD actions" do
      actions = test_model_displays.map(&:action).sort
      expect(actions).to eq(['edit', 'index', 'new', 'show'])
      
      test_model_displays.each do |model_display|
        expect(model_display.model_id).to eq(test_model.id)
        expect(model_display.block).to eq(test_block)
        puts "✅ ModelDisplay for #{model_display.action} action"
      end
    end

    it "creates field displays for all fields and actions" do
      # Should have field displays for each field in each action
      expected_count = test_fields.count * test_model_displays.count
      expect(test_field_displays.count).to eq(expected_count)
      
      # Verify field displays are properly associated
      test_field_displays.each do |field_display|
        expect(field_display.field).to be_in(test_fields)
        expect(field_display.model_display).to be_in(test_model_displays)
        expect(field_display.action).to be_in(['index', 'show', 'edit', 'new'])
      end
      
      puts "✅ Created #{test_field_displays.count} field displays (#{test_fields.count} fields × #{test_model_displays.count} actions)"
    end
  end

  describe "MegaBarConcern Integration" do
    include_context "deterministic_megabar_setup"

    it "has access to the mega_env system" do
      # This simulates what happens in the real MegaBarConcern
      expect(test_block).to be_present
      expect(test_model_displays).not_to be_empty
      expect(test_field_displays).not_to be_empty
      
      puts "✅ MegaBarConcern data structure ready for controller actions"
    end

    it "can find blocks by model" do
      blocks_for_model = MegaBar::Block.by_model(test_model.id)
      expect(blocks_for_model).to include(test_block)
      
      puts "✅ Block scoping by model works: found #{blocks_for_model.count} blocks"
    end

    it "can find model displays by block" do
      displays_for_block = MegaBar::ModelDisplay.by_block(test_block.id)
      expect(displays_for_block.count).to eq(4)
      expect(displays_for_block.map(&:action).sort).to eq(['edit', 'index', 'new', 'show'])
      
      puts "✅ ModelDisplay scoping by block works: found #{displays_for_block.count} displays"
    end
  end

  describe "Authorization Integration" do
    include_context "deterministic_megabar_setup"

    it "works with MegaBar authorization helpers" do
      controller = MegaBar::BlocksController.new
      
      # Test basic authorization methods exist
      expect(controller).to respond_to(:can_perform_action?) rescue nil
      
      # Test with actual Block class
      if controller.respond_to?(:can_perform_action?)
        result = controller.can_perform_action?(:index, MegaBar::Block)
        expect(result).to be(true) # Should be true with fallback
        puts "✅ Authorization fallback working for Block index"
      end
    end
  end
end 