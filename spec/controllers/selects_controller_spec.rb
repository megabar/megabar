module MegaBar
  require 'spec_helper'
  require_relative 'common'

  RSpec.describe MegaBar::SelectsController, :type => :controller do

    include_context "common" #pretty important!
    let(:a_record) {
      create(:select) unless model_class.first
      model_class.first
    }
    let(:controller_class) { MegaBar::SelectsController }
    let(:model_class) { MegaBar::Select }
    let(:controlller) { 'mega_bar/selects' }
    let(:invalid_attributes) { { 'field_display_id' => '' }  }
    let(:invalid_new) { {name: 'Select Select', make_block: ''} }
    let(:model_and_page) { create(:model_with_page, classname: 'Select', tablename: 'mega_bar_selects', name: 'Selects') }
    let(:page_name) { 'Selects Page' }
    let(:page_terms) { ['mega-bar', 'selects'] }
    let(:skip_invalids) { false }
    let(:spec_subject) { 'select' }
    let(:updated_attrs) { { 'field_display_id' =>  2 } }
    let(:uri) { '/mega-bar/selects' }
    let(:valid_attributes) {{ 'field_display_id' => '2' } }
    let(:valid_new) { { field_display_id: '1' } }
    let(:valid_session) { {} }

    let(:fields_and_displays) {
      create(:field_with_displays, field: 'field_display_id', tablename: 'mega_bar_selects', model_display_ids: model_model_display_ids )
    }
  end

end
