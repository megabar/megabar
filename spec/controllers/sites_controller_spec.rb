module MegaBar
  require 'spec_helper'
  require_relative 'common'
  RSpec.describe MegaBar::SitesController, :type => :controller do
    include_context "common" #pretty important!

    # MEGABAR almost gets you started with testing.. 
    # After you add a field, manually add that field to these:
    # ALSO, don't forget to add your fields manually to your factory in /spec/factories/site
    let(:updated_attrs) { { 'name' => 'valid name', 'code_name' => 'valid_code_name', 'theme_id' => 1, 'portfolio_id' => 1 } }
    let(:valid_attributes) {{ 'name' => 'valid name', 'code_name' => 'valid_code_name', 'theme_id' => '1', 'portfolio_id' => '1'  } }
    let(:valid_new) { { 'name' => 'valid new name', 'code_name' => 'valid_new_code_name', 'theme_id' => '1', 'portfolio_id' => '1'  } }
    let(:fields_and_displays) {  
      create(:field_with_displays, field: 'portfolio_id', tablename: 'mega_bar_sites', model_display_ids: model_model_display_ids) 
      create(:field_with_displays, field: 'name', tablename: 'mega_bar_sites', model_display_ids: model_model_display_ids) 
      create(:field_with_displays, field: 'code_name', tablename: 'mega_bar_sites', model_display_ids: model_model_display_ids) 
      create(:field_with_displays, field: 'theme_id', tablename: 'mega_bar_sites', model_display_ids: model_model_display_ids) 
    }
    # Megabar says, If you want to test invalid data, modify these: 
    let(:skip_invalids) { false }
    let(:invalid_new) { { 'Name': '' } }
    let(:invalid_attributes) {
      f = build(:site)
      { name: f[:Name], theme_id: nil, code_name: '' }
    }   

    let(:controlller) { 'mega_bar/sites' } #might need editing!

    # the rest of these you shouldn't have to mess with.
    let(:controller_class) { MegaBar::SitesController }
    let(:model_class) { MegaBar::Site }
    
    let(:model_and_page) { create(:model_with_page, classname: 'Site', tablename: 'mega_bar_sites', name: 'Site', modyule: 'MegaBar' ) }
    let(:page_terms) { ["MegaBar", "sites"]  }
    let(:page_name) { 'MegaBar page'   }
    let(:spec_subject) { 'site' }
    let(:uri) { 'sites' }
    let(:valid_session) { {} }
    let(:a_record) {
      create(:site) unless model_class.first
      model_class.first
    }

  end
end
