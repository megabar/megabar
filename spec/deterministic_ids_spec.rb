require 'spec_helper'

RSpec.describe "Deterministic ID System" do
  describe MegaBar::Template do
    it "generates deterministic IDs in the 12000-12999 range" do
      template = FactoryBot.create(:template, code_name: 'test_template')
      expect(template.id).to be_between(12000, 12999)
    end

    it "generates the same ID for the same code_name" do
      id1 = MegaBar::Template.deterministic_id('test_template')
      id2 = MegaBar::Template.deterministic_id('test_template')
      expect(id1).to eq(id2)
    end

    it "shows what ID will be generated for 'a_template'" do
      expected_id = MegaBar::Template.deterministic_id('a_template')
      puts "Template with code_name 'a_template' will have ID: #{expected_id}"
      
      template = FactoryBot.create(:template, code_name: 'a_template')
      expect(template.id).to eq(expected_id)
    end
  end

  describe MegaBar::Block do
    it "generates deterministic IDs in the 7000-7999 range" do
      # Need a layout_section_id for block creation
      block = FactoryBot.create(:block, name: 'test_block', layout_section_id: 1)
      expect(block.id).to be_between(7000, 7999)
    end

    it "shows what ID will be generated for a specific block" do
      expected_id = MegaBar::Block.deterministic_id(1, 'test_block')
      puts "Block with layout_section_id=1 and name='test_block' will have ID: #{expected_id}"
      
      block = FactoryBot.create(:block, name: 'test_block', layout_section_id: 1)
      expect(block.id).to eq(expected_id)
    end
  end

  describe "Factory Integration" do
    it "creates template and template_section with proper associations" do
      template = FactoryBot.create(:template, code_name: 'factory_test')
      template_section = FactoryBot.create(:template_section, template: template)
      
      puts "Created Template ID: #{template.id}"
      puts "Created TemplateSection ID: #{template_section.id}"
      puts "TemplateSection.template_id: #{template_section.template_id}"
      
      expect(template_section.template_id).to eq(template.id)
      expect(template_section.template).to eq(template)
    end
  end
end 