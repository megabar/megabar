require 'spec_helper'
module MegaBar
  describe Model, :type => :model do
    context 'skipping both callbacks' do 
      before(:each) do 
        Model.skip_callback("create",:after,:make_model_displays)
        Model.skip_callback("create",:after,:make_all_files)
      end
      it 'has a valid factory' do
        expect(FactoryGirl.create(:model)).to be_valid
      end
      it 'fixes bad class names' do 
        create(:model, classname: 'my_model')
        expect(Model.find(1).classname).to eq('MyModel')
      end

      it 'validates classname format' do 
        mod = Model.new(classname: '9lives', default_sort_field: 'id')
        expect(mod).to_not be_valid
        expect(mod.errors.messages[:classname][0]).to include 'Must start with a letter'
        mod = Model.new(classname: 'elvis+lives', default_sort_field: 'id')
        expect(mod).to_not be_valid
        expect(mod.errors.messages[:classname][0]).to include 'Must start with a letter'
      end
      it 'fixes bad table names' do 
         
      end

      it 'fixes bad module names' do 

      end
    end

    it 'creates four model displays ' do
      Model.skip_callback("create",:after,:make_all_files)
      FactoryGirl.create(:model_with_model_displays)
      expect(ModelDisplay.count).to eq(4)
    end

    it 'generates everything' do
      skip
    end
  end
end