module MegaBar
  require 'spec_helper'
  require_relative 'common'

  RSpec.describe MegaBar::ModelsController, :type => :controller do
    include_context "common" #pretty important!
    let(:controller_class) { MegaBar::ModelsController }
    let(:model_class) { MegaBar::Model }
    let(:controlller) { 'mega_bar/models' }
    let(:invalid_new) { {make_page: ''} }
    let(:page_name) { 'Models Page' }
    let(:page_terms) { ['mega-bar', 'models'] }
    let(:skip_invalids) { false }
    let(:spec_subject) { 'model' }
    let(:updated_attrs) { { 'classname' => 'testing' } }
    let(:uri) { '/mega-bar/models' }
    let(:valid_new) { {schema: 'sqlite', name: 'zoiks', default_sort_field: 'id', classname: 'oink', modyule: '', make_page: ''} }
    let(:valid_session) { {} }

    let(:model_and_page) { create(:model_with_page) }

    let(:fields_and_displays) { #have to at least have the required model fields.
      create(:field_with_displays, model_display_ids: model_model_display_ids)
      create(:field_with_displays, field: 'tablename', model_display_ids: model_model_display_ids )
      create(:field_with_displays, field: 'default_sort_field', model_display_ids: model_model_display_ids)
      create(:field_with_displays, field: 'name', model_display_ids: model_model_display_ids)
    }
    let(:a_record) {
      model_class.first
    }
    let(:valid_attributes) {
      m = build(:model)
      { classname: 'testing', name: m[:name], default_sort_field: m[:default_sort_field], id: m[:id]  }
    }
    let(:invalid_attributes) {
      m = build(:model)
      { classname: 'testing', name: '', id: m[:id]  }
    }

  end
end
