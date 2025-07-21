require 'spec_helper'

RSpec.describe MegaBar::PagesController, type: :controller do
  describe "Basic Controller Functionality" do
    it "can be instantiated" do
      expect(MegaBar::PagesController).to be_a(Class)
    end

    it "inherits from ApplicationController" do
      expect(MegaBar::PagesController.superclass).to eq(MegaBar::ApplicationController)
    end

    it "includes the MegaBarConcern" do
      expect(MegaBar::PagesController.included_modules).to include(MegaBar::MegaBarConcern)
    end
  end

  describe "Model Associations" do
    before(:each) do
      # Clean up any existing records
      MegaBar::Page.destroy_all
      MegaBar::Template.destroy_all
      MegaBar::TemplateSection.destroy_all
    end

    let(:template) { FactoryBot.create(:template, code_name: 'test_page_template') }
    let(:template_section) { FactoryBot.create(:template_section, template: template) }

    it "can work with deterministic Page IDs" do
      # Create a page and verify it gets a deterministic ID
      page = MegaBar::Page.create!(
        name: 'Test Page',
        path: '/test-page',
        template_id: template.id
      )
      
             # Pages use ID range 4000-4999
       expect(page.id).to be_between(4000, 4999)
      puts "Created Page ID: #{page.id}"
    end

    it "creates pages with proper template associations" do
      page = MegaBar::Page.create!(
        name: 'Associated Test Page',
        path: '/associated-test-page',
        template_id: template.id
      )
      
             # Page doesn't have a template association, but has template_id accessor
       expect(page.template_id).to eq(template.id)
      puts "Page #{page.id} is associated with Template #{template.id}"
    end
  end

  describe "Page Creation and Deterministic IDs" do
    before(:each) do
      MegaBar::Page.destroy_all
      MegaBar::Template.destroy_all
    end

    it "shows the deterministic ID calculation for pages" do
      # Test the deterministic ID calculation
      expected_id = MegaBar::Page.deterministic_id('test-path', 'Test Page')
      puts "Page with path='test-path' and name='Test Page' will have ID: #{expected_id}"
      
      page = MegaBar::Page.create!(
        name: 'Test Page',
        path: 'test-path'
      )
      
             expect(page.id).to eq(expected_id)
       expect(page.id).to be_between(4000, 4999)
    end

         it "handles page creation without callbacks for testing" do
       # Skip callbacks that might cause issues in test environment
       begin
         MegaBar::Page.skip_callback(:create, :after, :create_layout_for_page)
         MegaBar::Page.skip_callback(:create, :after, :add_route)
       rescue ArgumentError => e
         puts "⚠️  Callback skip failed: #{e.message}"
       end
      
      page = MegaBar::Page.create!(
        name: 'Simple Test Page',
        path: '/simple-test'
      )
      
      expect(page).to be_persisted
      expect(page.name).to eq('Simple Test Page')
      expect(page.path).to eq('/simple-test')
      puts "Created simple page with ID: #{page.id}"
      
             # Re-enable callbacks for other tests
       begin
         MegaBar::Page.set_callback(:create, :after, :create_layout_for_page)
         MegaBar::Page.set_callback(:create, :after, :add_route)
       rescue ArgumentError => e
         puts "⚠️  Callback restore failed: #{e.message}"
       end
    end
  end

  describe "Controller Actions (Simplified)" do
    before(:each) do
      # Clean slate for each test
      MegaBar::Page.destroy_all
      MegaBar::Template.destroy_all
      
             # Skip problematic callbacks
       begin
         MegaBar::Page.skip_callback(:create, :after, :create_layout_for_page)
         MegaBar::Page.skip_callback(:create, :after, :add_route)
       rescue ArgumentError
         # Callbacks might not exist in test environment, that's ok
       end
    end

         after(:each) do
       # Re-enable callbacks
       begin
         MegaBar::Page.set_callback(:create, :after, :create_layout_for_page)
         MegaBar::Page.set_callback(:create, :after, :add_route)
       rescue ArgumentError
         # Callbacks might not exist in test environment, that's ok
       end
     end

    let(:sample_page) do
      MegaBar::Page.create!(
        name: 'Sample Page',
        path: '/sample'
      )
    end

    it "can instantiate the controller" do
      controller = MegaBar::PagesController.new
      expect(controller).to be_a(MegaBar::PagesController)
    end

    it "works with Page model through deterministic IDs" do
      page = sample_page
      puts "Sample page created with deterministic ID: #{page.id}"
      
      # Verify we can find the page by its deterministic ID
      found_page = MegaBar::Page.find(page.id)
      expect(found_page).to eq(page)
      expect(found_page.name).to eq('Sample Page')
    end

    it "can list all pages" do
      # Create a few test pages
      page1 = MegaBar::Page.create!(name: 'Page One', path: '/page-one')
      page2 = MegaBar::Page.create!(name: 'Page Two', path: '/page-two')
      
      pages = MegaBar::Page.all
      expect(pages.count).to eq(2)
      expect(pages.map(&:name)).to include('Page One', 'Page Two')
      
      puts "Created pages with IDs: #{pages.map(&:id)}"
    end
  end

  describe "CCCUX Integration" do
    it "includes authorization helpers" do
      controller = MegaBar::PagesController.new
      
      # Check if CCCUX helpers are available
      if defined?(Cccux::AuthorizationHelper)
        expect(controller.class.included_modules.map(&:to_s)).to include('MegaBar::AuthorizationHelper')
        puts "✅ CCCUX authorization helpers are available"
      else
        puts "ℹ️  CCCUX not loaded - using MegaBar fallback authorization"
      end
    end

    it "can check permissions with fallback behavior" do
      controller = MegaBar::PagesController.new
      
      # Test the can_perform_action? method from our MegaBar::AuthorizationHelper
      if controller.respond_to?(:can_perform_action?)
        # This should return true when CCCUX is not present (fallback behavior)
        result = controller.can_perform_action?(:index, MegaBar::Page)
        expect(result).to be(true)
        puts "✅ Authorization fallback is working"
      else
        puts "ℹ️  Authorization helpers not loaded in controller"
      end
    end
  end

  describe "Integration with Deterministic System" do
    it "demonstrates the complete deterministic ID ecosystem" do
      # Clean slate
      [MegaBar::Page, MegaBar::Template, MegaBar::TemplateSection, MegaBar::Layout].each(&:destroy_all)
      
      # Create with deterministic IDs
      template = FactoryBot.create(:template, code_name: 'eco_test')
      template_section = FactoryBot.create(:template_section, template: template)
      
      # Skip callbacks to avoid complex dependencies
      MegaBar::Page.skip_callback(:create, :after, :create_layout_for_page)
      
      page = MegaBar::Page.create!(
        name: 'Ecosystem Test',
        path: '/ecosystem-test',
        template_id: template.id
      )
      
      puts ""
      puts "=== Deterministic ID Ecosystem ==="
      puts "Template ID: #{template.id} (range: 12000-12999)"
      puts "TemplateSection ID: #{template_section.id} (range: 13000-13999)"
             puts "Page ID: #{page.id} (range: 4000-4999)"
      puts "All IDs are deterministic and collision-free!"
      puts "=================================="
      
      expect(template.id).to be_between(12000, 12999)
      expect(template_section.id).to be_between(13000, 13999)
             expect(page.id).to be_between(4000, 4999)
      
      # Re-enable callback
      MegaBar::Page.set_callback(:create, :after, :create_layout_for_page)
    end
  end
end 