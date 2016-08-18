module MegaBar
  require 'spec_helper'
  require_relative 'common'
  RSpec.describe MegaBar::RadiosController, :type => :controller do
    include_context "common" #pretty important!

    # MEGABAR almost gets you started with testing.. 
    # After you add a field, manually add that field to these:
    # ALSO, don't forget to add your fields manually to your factory in /spec/factories/radio
    let(:updated_attrs) { { 'tbd' => 'tbd' } }
    let(:valid_attributes) {{ 'tbd' => "tbd" } }
    let(:valid_new) { { tbd: 'tbd'} }
    let(:fields_and_displays) {  create(:field_with_displays, field: 'tbd', tablename: 'mega_bar_radios', model_display_ids: model_model_display_ids) }
    # Megabar says, If you want to test invalid data, modify these: 
    let(:skip_invalids) { true }
    let(:invalid_new) { {tbd: ''} }
    let(:invalid_attributes) {
      f = build(:radio)
      { tbd: f[:tbd] }
    }
    let(:controlller) { 'radios' } #might need editing!

    # the rest of these you shouldn't have to mess with.
    let(:controller_class) { MegaBar::RadiosController }
    let(:model_class) { MegaBar::Radio }
    
    let(:model_and_page) { create(:model_with_page, classname: 'Radio', tablename: 'mega_bar_radios', name: 'Radio', modyule: 'MegaBar' ) }
    let(:page_terms) { ["MegaBar", "radios"]  }
    let(:page_name) { 'MegaBar page'   }
    let(:spec_subject) { 'radio' }
    let(:uri) { 'radios' }
    let(:valid_session) { {} }
    let(:a_record) {
      create(:radio) unless model_class.first
      model_class.first
    }

  end
end
