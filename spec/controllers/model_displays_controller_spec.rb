module MegaBar
  require_relative 'common'
  require 'spec_helper'
  RSpec.describe MegaBar::ModelDisplaysController, :type => :controller do
    include_context "common" #pretty important!
    let(:a_record) {
      create(:model_display) unless model_class.first
      model_class.first
    }
    let(:controller_class) { MegaBar::ModelDisplaysController }
    let(:model_class) { MegaBar::ModelDisplay }
    let(:controlller) { 'mega_bar/model_displays' }
    let(:invalid_attributes) { { 'block_id' => '' }  }
    let(:invalid_new) { {header: 'Model Display Model Display oink', make_data_display: ''} }
    let(:model_and_page) { create(:model_with_page, classname: 'ModelDisplay', tablename: 'mega_bar_model_displays', name: 'Model Displays') }
    let(:page_name) { 'Model Display Page' }
    let(:page_terms) { ['mega-bar', 'model_displays'] }
    let(:spec_subject) { 'model_display' }
    let(:updated_attrs) { { 'header' => 'testing' } }
    let(:uri) { '/mega-bar/model_displays' }
    let(:valid_attributes) { { 'header' => "testing"  } }
    let(:valid_new) { { header: 'new Model Display', block_id: '1', model_id: '1', action: 'beep', format: 'quack'} }
    let(:valid_session) { {} }

    let(:fields_and_displays) {
      create(:field_with_displays, field: 'header', tablename: 'mega_bar_model_displays')
      create(:field_with_displays, field: 'block_id', tablename: 'mega_bar_model_displays' )
      create(:field_with_displays, field: 'action', tablename: 'mega_bar_model_displays' )
      create(:field_with_displays, field: 'format', tablename: 'mega_bar_model_displays' )
      create(:field_with_displays, field: 'model_id', tablename: 'mega_bar_model_displays' )
    }
    let(:invalid_attributes) {
      f = build(:model_display)
      { header: f[:header],  block_id: nil, format: nil, id: f[:id]  }
    }

  end
end
