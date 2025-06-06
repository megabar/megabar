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
        MegaBar::Field.skip_callback("create",:after,:make_migration)
        MegaBar::Model.skip_callback("create",:after,:make_all_files)
        MegaBar::Model.set_callback("create", :after, :make_page_for_model)
        # might be needed skip and or set: MegaBar::Model.skip_callback(       'save',   :after, :make_position_field)
   
        MegaBar::Page.set_callback("create", :after, :create_layout_for_page)
        MegaBar::Layout.set_callback('create', :after, :create_layable_sections)
        MegaBar::LayoutSection.set_callback('create', :after, :create_block_for_section)
        MegaBar::Block.set_callback("create", :after, :make_model_displays)
        model = create(:model)
      end
      after(:each) do
        Model.find(1).delete
        MegaBar::Field.set_callback("create",:after,:make_migration)
        MegaBar::Model.set_callback("create",:after,:make_all_files)
        MegaBar::Model.destroy_all
        MegaBar::Page.destroy_all
        MegaBar::ModelDisplayFormat.destroy_all
      end


      describe 'and instance vars' do
        let(:object) { FakesController.new }
        let(:params) {{model_id: 1, controller: "mega_bar/models", action: "index"}}
        let(:params_with_sort) {{model_id: 1, controller: "mega_bar/models", action: "new", sort: "classname"}}
        let(:params_with_direction) {{model_id: 1, controller: "mega_bar/models", action: "new", direction: "asc"}}
        let(:mega_class) { object.constant_from_controller(params[:controller]).constantize }
        let(:mega_model_properties) { Model.find(1) }

        it "gets the default sort column right" do

          expect(object.sort_column(mega_class, mega_model_properties, params)).to eq('id')
        end
        it "gets a set sort column right" do

          expect(object.sort_column(mega_class, mega_model_properties, params_with_sort)).to eq('classname')
        end
        it "gets the default sort DIRECTION right" do
          expect(object.sort_direction(params, mega_model_properties)).to eq('desc')
        end
        it "gets the default sort DIRECTION right" do
          expect(object.sort_direction(params_with_direction, mega_model_properties)).to eq('asc')
        end
        it 'gets the form path' do
          skip('url_for doesnt work in this context')
          expect(object.form_path(params)).to eq('??')
        end
        it 'sets displayable to true if format is textbox', focus: true do
          expect(object.is_displayable?('textbox')).to eq(true)
        end
        it 'sets displayable to false if format is off', focus: true do
          expect(object.is_displayable?('off')).to eq(false)
        end
        it ' constant_from_controller returns  a good constant string ' do
          expect(object.constant_from_controller('mega_bar/models')).to eq('MegaBar::Model')
        end
        skip 'can filter'  do
          # $20 bounty
        end
        skip 'can paginate' do
          # $20 bounty
        end
        skip 'can acts_as_list' do
          # $20 bounty
        end

      end
    end
  end
end
