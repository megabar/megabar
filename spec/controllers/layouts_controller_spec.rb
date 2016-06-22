module MegaBar
  require 'spec_helper'
  require_relative 'common'

  RSpec.describe MegaBar::LayoutsController, :type => :controller do
  include_context "common" #pretty important!
  let(:a_record) { model_class.first }
  let(:controller_class) { MegaBar::LayoutsController }
  let(:model_class) { MegaBar::Layout }
  let(:controlller) { 'mega_bar/layouts' }
  let(:invalid_attributes) { { 'page_id' => '' }  }
  let(:invalid_new) { {name: 'Layouts Layout', make_block: ''} }
  let(:model_and_page) { create(:model_with_page, classname: 'Layout', tablename: 'mega_bar_layouts', name: 'Layouts') }
  let(:page_name) { 'Layout Page' }
  let(:page_terms) { ['mega-bar', 'layouts'] }
  let(:skip_invalids) { false }
  let(:spec_subject) { 'layout' }
  let(:updated_attrs) { { 'name' => 'testing' } }
  let(:uri) { '/mega-bar/layouts' }
  let(:valid_attributes) {{ 'name' => "testing" } }
  let(:valid_new) { { name: 'new layout', page_id: '1', make_block: ''} }
  let(:valid_session) { {} }

  let(:fields_and_displays) {
    create(:field_with_displays, field: 'name', tablename: 'mega_bar_layouts', model_display_ids: model_model_display_ids)
    create(:field_with_displays, field: 'page_id', tablename: 'mega_bar_layouts', model_display_ids: model_model_display_ids)
  }
  end
end
