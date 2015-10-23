module MegaBar
  require_relative 'common'
  require 'spec_helper'
  RSpec.describe MegaBar::FieldDisplaysController, :type => :controller do
    include_context "common" #pretty important!
    let(:a_record) {
      create(:field_display) unless model_class.first
      model_class.first
    }
    let(:controller_class) { MegaBar::FieldDisplaysController }
    let(:model_class) { MegaBar::FieldDisplay }
    let(:controlller) { 'mega_bar/field_displays' }
    let(:invalid_attributes) { { 'model_display_id' => '' }  }
    let(:invalid_new) { {header: 'Field Display Field Display oink', make_data_display: ''} }
    let(:model_and_page) { create(:model_with_page, classname: 'FieldDisplay', tablename: 'mega_bar_field_displays', name: 'Field Displays') }
    let(:page_name) { 'Field Display Page' }
    let(:page_terms) { ['mega-bar', 'field_displays'] }
    let(:skip_invalids) { false }
    let(:spec_subject) { 'field_display' }
    let(:updated_attrs) { { 'header' => 'testing' } }
    let(:uri) { '/mega-bar/field_displays' }
    let(:valid_attributes) { { 'header' => "testing"  } }
    let(:valid_new) { { header: 'new Field Display', model_display_id: '14', field_id: '44'} }
    let(:valid_session) { {} }

    let(:fields_and_displays) {
      create(:field_with_displays, field: 'header', tablename: 'mega_bar_field_displays')
      create(:field_with_displays, field: 'model_display_id', tablename: 'mega_bar_field_displays' )
      create(:field_with_displays, field: 'field_id', tablename: 'mega_bar_field_displays' )
    }

    let(:valid_attributes) {
      fd = build(:field_display)
      { header: 'testing', model_display_id: '1', field_id: '1', format: fd[:format], id: fd[:id]  }
    }

    let(:invalid_attributes) {
      f = build(:field_display)
      { header: f[:header],  model_display_id: nil, format: nil, id: f[:id]  }
    }

  end
end
