require 'spec_helper'
module MegaBar
  describe Model, :type => :model do
    context 'skipping both callbacks' do 
      before(:each) do 
        Model.skip_callback("create",:after,:make_model_displays)
        Model.skip_callback("create",:after,:make_all_files)
      end
      after(:each) do
        Model.set_callback('create', :after, :make_model_displays)
        Model.set_callback('create', :after, :make_all_files)
      end
      it 'has a valid factory' do
        expect(FactoryGirl.create(:model)).to be_valid
      end
      it 'fixes bad class names' do 
        create(:model, classname: 'my_model')
        expect(Model.find(1).classname).to eq('MyModel')
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
        mod = create(:model, modyule: 'mega_bar', id:2)
        expect(mod.modyule).to eq('MegaBar')
        mod = create(:model, modyule: 'some_other_module', id:3)
        expect(mod.modyule).to eq('SomeOtherModule')
      end
    end
    context 'with make_all_files disabled' do
      before(:each) do 
        Model.skip_callback('create',:after,:make_all_files)
        create(:model_with_model_displays)
      end
      after(:each) do
        Model.set_callback('create', :after, :make_all_files)
        Model.find(1).destroy
      end

      it 'creates four model displays ' , focus: true  do
        expect(ModelDisplay.count).to eq(4)
      end
    end

    context 'with make_model_displays disabled for generator test' do
      before(:each) do 
        Model.skip_callback('create',:after,:make_model_displays)
        create(:model, classname:'TestCase', modyule: '')
      end
      after(:each) do
        Model.set_callback('create', :after, :make_model_displays)
        File.delete('spec/internal/app/models/test_case.rb')
        File.delete('spec/internal/app/controllers/test_cases_controller.rb')
        File.delete('spec/internal/spec/controllers/test_cases_controller_spec.rb')
        File.delete('spec/internal/spec/factories/test_case.rb')
        File.delete(Dir.glob('db/migrate/*create_test_cases.rb')[0])
        Model.find(1).destroy
      end

      it 'generates everything for a non megabar model' do 
        expect(File).to exist('spec/internal/app/models/test_case.rb') 
        expect(File).to exist('spec/internal/app/controllers/test_cases_controller.rb') 
        expect(File).to exist('spec/internal/spec/controllers/test_cases_controller_spec.rb') 
        expect(File).to exist('spec/internal/spec/factories/test_case.rb') 
        expect(Dir.glob('db/migrate/*create_test_cases.rb').empty?).to be_falsey
        # cant test routes here.. boo. expect(:get => "/test-cases").to route_to(:controller => 'test_cases#index')
      end
    end

  end
end