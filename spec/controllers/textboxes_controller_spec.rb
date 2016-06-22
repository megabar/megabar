module MegaBar
  require 'spec_helper'
  require_relative 'common'
  RSpec.describe MegaBar::TextboxesController, :type => :controller do

    include_context "common" #pretty important!
    let(:a_record) {
      create(:textbox) unless model_class.first
      model_class.first
    }
    let(:controller_class) { MegaBar::TextboxesController }
    let(:model_class) { MegaBar::Textbox }
    let(:controlller) { 'mega_bar/textboxes' }
    let(:invalid_attributes) { { 'field_display_id' => '' }  }
    let(:invalid_new) { {name: 'TextBox TextBox', make_block: ''} }
    let(:model_and_page) { create(:model_with_page, classname: 'Textbox', tablename: 'mega_bar_textboxes', name: 'Textboxes') }
    let(:page_name) { 'Textboxes Page' }
    let(:page_terms) { ['mega-bar', 'textboxes'] }
    let(:skip_invalids) { false }
    let(:spec_subject) { 'textbox' }
    let(:updated_attrs) { { 'field_display_id' =>  2 } }
    let(:uri) { '/mega-bar/textboxes' }
    let(:valid_attributes) {{ 'field_display_id' => '2' } }
    let(:valid_new) { { field_display_id: '1' } }
    let(:valid_session) { {} }

    let(:fields_and_displays) {
      create(:field_with_displays, field: 'field_display_id', tablename: 'mega_bar_textboxes', model_display_ids: model_model_display_ids )
    }
  end

end
