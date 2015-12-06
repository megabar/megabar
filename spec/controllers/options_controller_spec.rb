module MegaBar
  require 'spec_helper'
  require_relative 'common'
  RSpec.describe MegaBar::OptionsController, :type => :controller do

    include_context "common" #pretty important!
    let(:a_record) {
      create(:option) unless model_class.first
      model_class.first
    }
    let(:controller_class) { MegaBar::OptionsController }
    let(:model_class) { MegaBar::Option }
    let(:controlller) { 'mega_bar/options' }
    let(:invalid_attributes) { { 'field_id' => '' }  }
    let(:invalid_new) { {name: 'Options Option', make_block: ''} }
    let(:model_and_page) { create(:model_with_page, classname: 'Option', tablename: 'mega_bar_options', name: 'Options') }
    let(:page_name) { 'Options Page' }
    let(:page_terms) { ['mega-bar', 'options'] }
    let(:skip_invalids) { false }
    let(:spec_subject) { 'option' }
    let(:updated_attrs) { { 'text' =>  'new option text' } }
    let(:uri) { '/mega-bar/options' }
    let(:valid_attributes) {{ field_id: '1', text: 'new option text', value: 'new value' } }
    let(:valid_new) { { field_id: '1', text: 'new option text', value: 'new value' } }
    let(:valid_session) { {} }

    let(:fields_and_displays) {
      create(:field_with_displays, field: 'text', tablename: 'mega_bar_options')
      create(:field_with_displays, field: 'field_id', tablename: 'mega_bar_options' )
      create(:field_with_displays, field: 'value', tablename: 'mega_bar_options')
    }


  end

end
