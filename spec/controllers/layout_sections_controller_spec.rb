module MegaBar
  require 'spec_helper'
  require_relative 'common'
  RSpec.describe MegaBar::LayoutSectionsController, :type => :controller do
    include_context "common" #pretty important!

    # MEGABAR almost gets you started with testing..
    # After you add a field, manually add that field to these:
    # ALSO, don't forget to add your fields manually to your factory in /spec/factories/layout_section
    let(:updated_attrs) { {  'code_name' => 'valid_code_name' } }
    let(:valid_attributes) { {  'code_name' => 'valid_code_name' } }
    let(:valid_new) { { 'code_name' => 'updated_code_name' } }
    let(:fields_and_displays) {
       create(:field_with_displays, field: 'code_name', tablename: 'mega_bar_layout_sections', model_display_ids: model_model_display_ids)
    }
    # Megabar says, If you want to test invalid data, modify these:
    let(:skip_invalids) { true }
    let(:invalid_new) { {code_name: ''} }
    let(:invalid_attributes) {
      f = build(:layout_section)
      { code_name: nil}
    }
    let(:controlller) { 'mega_bar/layout_sections' } #might need editing!

    # the rest of these you shouldn't have to mess with.
    let(:controller_class) { MegaBar::LayoutSectionsController }
    let(:model_class) { MegaBar::LayoutSection }

    let(:model_and_page) { create(:model_with_page, classname: 'LayoutSection', tablename: 'mega_bar_layout_sections', name: 'LayoutSection', modyule: 'MegaBar' ) }
    let(:page_terms) { ["MegaBar", "layout-sections"]  }
    let(:page_name) { 'MegaBar page'   }
    let(:spec_subject) { 'layout_section' }
    let(:uri) { 'layout-sections' }
    let(:valid_session) { {} }
    let(:a_record) {
      create(:layout_section) unless model_class.first
      model_class.first
    }

  end
end
