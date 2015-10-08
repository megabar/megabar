module MegaBar
  require 'spec_helper'
  require_relative 'common'
  RSpec.describe MegaBar::ModelDisplayFormatsController, :type => :controller do
    include_context "common" #pretty important!
    let(:controller_class) { MegaBar::ModelDisplayFormatsController }
    let(:model_class) { MegaBar::ModelDisplayFormat }
    let(:a_record) {
      create(:model_display_format) unless model_class.first
      model_class.first
    }
    let(:controlller) { 'mega_bar/model_display_formats' }
    let(:invalid_attributes) { { 'block_id' => '' }  }
    let(:invalid_new) { {header: 'Model Display Format Model Display Format oink'} }
    let(:model_and_page) { create(:model_with_page, classname: 'ModelDisplayFormat', tablename: 'mega_bar_model_display_formats', name: 'Model Display Formats') }
    let(:page_name) { 'Model Display Formats Page' }
    let(:page_terms) { ['mega-bar', 'model_display_formats'] }
    let(:spec_subject) { 'model_display_format' }
    let(:updated_attrs) { { 'name' => 'testing' } }
    let(:uri) { '/mega-bar/model_display_formats' }
    let(:valid_attributes) { { 'name' => "testing"  } }
    let(:valid_new) { { name: 'new Model Display Format'} }
    let(:valid_session) { {} }

    let(:fields_and_displays) {
      create(:field_with_displays, field: 'name', tablename: 'mega_bar_model_display_formats')
    }
    let(:invalid_attributes) {
      { 'name' => 'boink'}
    }
  end
end
