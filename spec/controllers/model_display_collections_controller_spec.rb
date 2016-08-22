module MegaBar
  require 'spec_helper'
  require_relative 'common'
  RSpec.describe MegaBar::ModelDisplayCollectionsController, :type => :controller do
    include_context "common" #pretty important!

    # MEGABAR almost gets you started with testing.. 
    # After you add a field, manually add that field to these:
    # ALSO, don't forget to add your fields manually to your factory in /spec/factories/model_display_collection
    let(:updated_attrs) { { 'tbd' => 'tbd' } }
    let(:valid_attributes) {{ 'tbd' => "tbd" } }
    let(:valid_new) { { tbd: 'tbd'} }
    let(:fields_and_displays) {  create(:field_with_displays, field: 'tbd', tablename: 'mega_bar_model_display_collections', model_display_ids: model_model_display_ids) }
    # Megabar says, If you want to test invalid data, modify these: 
    let(:skip_invalids) { true }
    let(:invalid_new) { {tbd: ''} }
    let(:invalid_attributes) {
      f = build(:model_display_collection)
      { tbd: f[:tbd] }
    }
    let(:controlller) { 'model_display_collections' } #might need editing!

    # the rest of these you shouldn't have to mess with.
    let(:controller_class) { MegaBar::ModelDisplayCollectionsController }
    let(:model_class) { MegaBar::ModelDisplayCollection }
    
    let(:model_and_page) { create(:model_with_page, classname: 'ModelDisplayCollection', tablename: 'mega_bar_model_display_collections', name: 'ModelDisplayCollection', modyule: 'MegaBar' ) }
    let(:page_terms) { ["MegaBar", "model-display-collections"]  }
    let(:page_name) { 'MegaBar page'   }
    let(:spec_subject) { 'model_display_collection' }
    let(:uri) { 'model-display-collections' }
    let(:valid_session) { {} }
    let(:a_record) {
      create(:model_display_collection) unless model_class.first
      model_class.first
    }

  end
end
