module MegaBar
  require 'spec_helper'
  require_relative 'common'

  RSpec.describe MegaBar::TextreadsController, :type => :controller do
    include_context "common" #pretty important!
    let(:a_record) {
      create(:textread) unless model_class.first
      model_class.first
    }
    let(:controller_class) { MegaBar::TextreadsController }
    let(:model_class) { MegaBar::Textread }
    let(:controlller) { 'mega_bar/textreads' }
    let(:invalid_attributes) { { 'field_display_id' => '' }  }
    let(:invalid_new) { {name: 'TextRead TextRead', make_block: ''} }
    let(:model_and_page) { create(:model_with_page, classname: 'Textread', tablename: 'mega_bar_textreads', name: 'Textreads') }
    let(:page_name) { 'Textreads Page' }
    let(:page_terms) { ['mega-bar', 'textreads'] }
    let(:skip_invalids) { false }
    let(:spec_subject) { 'textread' }
    let(:updated_attrs) { { 'field_display_id' =>  2 } }
    let(:uri) { '/mega-bar/textreads' }
    let(:valid_attributes) {{ 'field_display_id' => '2' } }
    let(:valid_new) { { field_display_id: '1' } }
    let(:valid_session) { {} }

    let(:fields_and_displays) {
      create(:field_with_displays, field: 'field_display_id', tablename: 'mega_bar_textreads', model_display_ids: model_model_display_ids )
    }
  end

end
