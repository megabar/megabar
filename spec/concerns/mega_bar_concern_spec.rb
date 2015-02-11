module MegaBar
  require 'spec_helper'

  RSpec.describe MegaBar::MegaBarConcern, :type => :controller do 
    before do
      class FakesController < ApplicationController
        include MegaBarConcern
      end
    end
    
    context 'with init' do 
      before(:each) do
        Field.skip_callback("create",:after,:make_migration)
        Model.skip_callback("create",:after,:make_all_files)
        model = create(:model)
      end
      after(:each) do 
        Model.find(1).delete
        MegaBar::Model.set_callback("create",:after,:make_all_files)
        MegaBar::Model.set_callback("create",:after,:make_model_displays)
      
      end


      describe 'and instance vars' do
        let(:object) { FakesController.new }
        let(:params) {{model_id: 1, controller: "mega_bar/models", action: "index"}}
        let(:params_with_sort) {{model_id: 1, controller: "mega_bar/models", action: "new", sort: "classname"}}
        let(:params_with_direction) {{model_id: 1, controller: "mega_bar/models", action: "new", direction: "desc"}}
        let(:mega_class) { object.constant_from_controller(params[:controller]).constantize }
        let(:mega_model_properties) { Model.find(1) }
       
        it "gets the default sort column right" do
          expect(object.sort_column(mega_class, mega_model_properties, params)).to eq('id')
        end
        it "gets a set sort column right" do
          expect(object.sort_column(mega_class, mega_model_properties, params_with_sort)).to eq('classname')
        end
        it "gets the default sort DIRECTION right" do
          expect(object.sort_direction(params)).to eq('asc')
        end
        it "gets the default sort DIRECTION right" do
          expect(object.sort_direction(params_with_direction)).to eq('desc')
        end
        it 'gets the form path' do 
          skip('url_for doesnt work in this context')
          expect(object.form_path(params)).to eq('??')
        end
        it 'sets displayable to true if format is textbox' do
          expect(object.is_displayable?('textbox')).to eq(true) 
        end  
        it 'sets displayable to false if format is off' do
          expect(object.is_displayable?('off')).to eq(false) 
        end  
        it ' constant_from_controller returns  a good constant string ' do
          expect(object.constant_from_controller('mega_bar/models')).to eq('MegaBar::Model') 
        end
        it ''

      end
    end
  end
end