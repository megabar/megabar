module MegaBar
  require 'spec_helper'
  require_relative 'common'
  RSpec.describe MegaBar::FieldsController, :type => :controller do
    include_context "common" #pretty important!
    let(:controller_class) { MegaBar::FieldsController }
    let(:model_class) { MegaBar::Field }
    let(:controlller) { 'mega_bar/fields' }
    let(:invalid_new) { {make_page: ''} }
    let(:a_record) { create(:field) }
    let(:page_name) { 'Fields Page' }
    let(:page_terms) { ['mega-bar', 'fields'] }
    let(:spec_subject) { 'field' }

    let(:updated_attrs) { { 'default_data_format_edit' => 'sselect' } }
    let(:uri) { '/mega-bar/fields' }
    let(:valid_new) { { model_id: '1', tablename: 'mega_bar_fields', field: 'whatever', default_data_format: 'text', default_data_format_edit: 'textbox', make_field_displays: ''} }
    # let(:valid_new) { {schema: 'sqlite', name: 'zoiks', default_sort_field: 'id', classname: 'oink', modyule: '', make_page: ''} }


    let(:valid_session) { {} }

    let(:model_and_page) { create(:model_with_page, classname: 'Field', tablename: 'mega_bar_fields', name: 'Fields') }
    let(:fields_and_displays) { #have to at least have the required model fields.
      create(:field_with_displays, field: 'model_id' )
      create(:field_with_displays, field: 'tablename' )
      create(:field_with_displays, field: 'field')
      create(:field_with_displays, field: 'default_data_format_edit')
      create(:field_with_displays, field: 'default_data_format')

    }
    let(:a_record) {
       model_class.first
    }
    # let(:all_records) {
    #   model_class.all
    # }
    let(:valid_attributes) {
      f = build(:field, tablename: 'fields', field: 'tablenamex')
      { tablename: f[:tablename], field: f[:field], model_id: '1', id: f[:id], default_data_format_edit: "sselect"  }
    }

    let(:invalid_attributes) {
      f = build(:field)
      { tablename: nil, field: nil, model_id: nil, id: f[:id]  }
    }

  end
end
