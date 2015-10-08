module MegaBar
  require_relative 'common'
  require 'spec_helper'
  RSpec.describe MegaBar::BlocksController, :type => :controller do
    include_context "common" #pretty important!
    let(:a_record) { model_class.first }
    let(:controller_class) { MegaBar::BlocksController }
    let(:model_class) { MegaBar::Block }
    let(:controlller) { 'mega_bar/blocks' }
    let(:invalid_attributes) { { 'layout_id' => '' }  }
    let(:invalid_new) { {name: 'Block Block', make_block: ''} }
    let(:model_and_page) { create(:model_with_page, classname: 'Block', tablename: 'mega_bar_blocks', name: 'Blocks') }
    let(:page_name) { 'Block Page' }
    let(:page_terms) { ['mega-bar', 'blocks'] }
    let(:spec_subject) { 'block' }
    let(:updated_attrs) { { 'name' => 'testing' } }
    let(:uri) { '/mega-bar/blocks' }
    let(:valid_attributes) {{ 'name' => "testing" } }
    let(:valid_new) { { name: 'new block', layout_id: '1', new_model_display: ''} }
    let(:valid_session) { {} }

    let(:fields_and_displays) {
      create(:field_with_displays, field: 'name', tablename: 'mega_bar_blocks')
      create(:field_with_displays, field: 'layout_id', tablename: 'mega_bar_blocks' )
    }
  end

end
