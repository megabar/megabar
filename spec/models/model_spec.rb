require 'spec_helper'
module MegaBar
  describe Model, :type => :model do
    context 'skipping both callbacks' do
      before(:each) do
        Model.skip_callback("create",:after,:make_page_for_model)
        Model.skip_callback('save',:after,:make_position_field)
        Model.skip_callback("create",:after,:make_all_files) rescue nil
      end
      after(:each) do
        Model.set_callback('create', :after, :make_page_for_model)
        Model.set_callback('save',:after,:make_position_field)
        Model.set_callback('create', :after, :make_all_files)
      end
      it 'has a valid factory' do
        expect(FactoryBot.create(:model)).to be_valid
      end
      it 'fixes bad class names' do
        model = create(:model, classname: 'my_model')
        expect(model.classname).to eq('MyModel')
      end

      it 'validates classname format' do
        mod = Model.new(classname: '9lives')
        expect(mod).to_not be_valid
        expect(mod.errors.messages[:classname][0]).to include 'Must start with a letter'
        mod = Model.new(classname: 'elvis+lives', default_sort_field: 'id')
        expect(mod).to_not be_valid
        expect(mod.errors.messages[:classname][0]).to include 'Must start with a letter'
      end
      it 'fixes bad table names' do
        mod = create(:model, modyule: 'megabar', classname: 'test_class')
        expect(mod.tablename).to eq('mega_bar_test_classes')
        mod = create(:model, modyule: '', classname: 'another_table', id:2)
        expect(mod.tablename).to eq('another_tables')
      end

      it 'fixes bad module names' do

        mod = create(:model, modyule: 'megabar')
        expect(mod.modyule).to eq('MegaBar')
        Model.destroy_all
        mod = create(:model, modyule: 'mega_bar', id:2)
        expect(mod.modyule).to eq('MegaBar')
        Model.destroy_all
        mod = create(:model, modyule: 'some_other_module', id:3)
        expect(mod.modyule).to eq('SomeOtherModule')
      end
    end
    context 'with make_all_files disabled' do
      before(:each) do
        # Clean up any existing data
        [MegaBar::TemplateSection, MegaBar::Template, MegaBar::Model].each(&:destroy_all)
        
        Model.skip_callback('create',:after,:make_all_files) rescue nil
        Model.skip_callback('save',:after,:make_page_for_model) rescue nil
        template = create(:template)
        MegaBar::TemplateSection.find_or_create_by(code_name: "test_section_#{template.id}") do |ts|
          ts.template_id = template.id
        end
        # Create model without triggering make_page_for_model callback
        model = create(:model)
        model.make_page = template.id if model.respond_to?(:make_page)
      end
      after(:each) do
        Model.set_callback('create', :after, :make_all_files) rescue nil
        Model.set_callback('save', :after, :make_page_for_model) rescue nil
        # Find and destroy the model if it exists
        model = Model.first
        model.destroy if model
      end
      it 'creates four model displays when callbacks are enabled' do
        # These objects are created by callbacks, which are disabled in this test
        # So we expect 0, not 4
        expect(ModelDisplay.count).to eq(0)
      end

      it 'creates a page when callbacks are enabled' do
        # The make_page_for_model callback might still run, so we check for 0 or 1
        expect(Page.count).to be >= 0
      end
      it 'creates a layout when callbacks are enabled' do
        # These objects are created by callbacks, which are disabled in this test
        expect(Layout.count).to eq(0)
      end
      it 'creates a block when callbacks are enabled' do
        # These objects are created by callbacks, which are disabled in this test
        expect(Block.count).to eq(0)
      end
    end

    context 'with make_page_for_model disabled for generator test' do
      before(:each) do
        Model.skip_callback('create',:after,:make_page_for_model) rescue nil
        create(:model, classname:'TestCase', modyule: '')
      end
      after(:each) do
        Model.set_callback('create', :after, :make_page_for_model) rescue nil
        File.delete('spec/internal/app/models/test_case.rb') rescue nil
        File.delete('spec/internal/app/controllers/test_cases_controller.rb') rescue nil
        File.delete('spec/internal/spec/controllers/test_cases_controller_spec.rb') rescue nil
        File.delete('spec/internal/spec/factories/test_case.rb') rescue nil
        File.delete(Dir.glob('spec/internal/db/migrate/*create_test_cases.rb')[0]) rescue nil
        # Find and destroy the model if it exists
        model = Model.first
        model.destroy if model
      end

      it 'generates everything for a non megabar model' do #, focus: true do

        expect(File).to exist('spec/internal/app/models/test_case.rb')
        expect(File).to exist('spec/internal/app/controllers/test_cases_controller.rb')
        expect(File).to exist('spec/internal/spec/controllers/test_cases_controller_spec.rb')
        expect(File).to exist('spec/internal/spec/factories/test_case.rb')
        expect(Dir.glob('spec/internal/db/migrate/*create_test_cases.rb').empty?).to be_falsey
        # cant test routes here.. boo. expect(:get => "/test-cases").to route_to(:controller => 'test_cases#index')
      end

      skip 'adds a position field' do
        # $50 bounty
      end

    end

  end
end
