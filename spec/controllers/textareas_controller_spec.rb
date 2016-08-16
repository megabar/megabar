module MegaBar
  require 'spec_helper'
  require_relative 'common'

  RSpec.describe MegaBar::TextareasController, :type => :controller do
    include_context "common" #pretty important!
    let(:a_record) {
      create(:textarea) unless model_class.first
      model_class.first
    }
    let(:controller_class) { MegaBar::TextareasController }
    let(:updated_attrs) {  { 'field_display_id' =>  2 } }
    let(:valid_attributes) { { 'field_display_id' => '2' } }
    let(:valid_new) { { field_display_id: '5' } }
    let(:fields_and_displays) {
      create(:field_with_displays, field: 'field_display_id', tablename: 'mega_bar_textareas', model_display_ids: model_model_display_ids )
    }
    # Megabar says, If you want to test invalid data, modify these: 
    let(:model_class) { MegaBar::Textarea }
    let(:skip_invalids) { false }
    let(:invalid_new) { { name: 'TextArea TextArea', make_block: ''} }
    let(:invalid_attributes) { { 'field_display_id' => '' }  }

    # the rest of these you shouldn't have to mess with.
    let(:controlller) { 'mega_bar/textareas' }
    let(:model_and_page) { create(:model_with_page, classname: 'Textarea', tablename: 'mega_bar_textareas', name: 'Textarea', modyule: 'MegaBar' ) }
    let(:page_terms) { ["MegaBar", "textareas"]  }
    let(:page_name) { 'MegaBar page'   }
    let(:spec_subject) { 'textarea' }
    let(:uri) { 'textareas' }
    let(:valid_session) { {} }

  end
end
