module MegaBar
  require 'spec_helper'
  require_relative 'common'
  RSpec.describe MegaBar::SiteJoinsController, :type => :controller do
    include_context "common" #pretty important!

    # MEGABAR almost gets you started with testing.. 
    # After you add a field, manually add that field to these:
    # ALSO, don't forget to add your fields manually to your factory in /spec/factories/site_join
    let(:updated_attrs) { {  'site_id' => 1, 'siteable_id' => 1, 'siteable_type' => 'MegaBar::Block' } }
    let(:valid_attributes) {{ 'site_id' => '1', 'siteable_id' => '1', 'siteable_type' => 'MegaBar::Block'  } }
    let(:valid_new) { { 'site_id' => '1', 'siteable_id' => '1', 'siteable_type' => 'MegaBar::Layout' } }
    let(:fields_and_displays) {  
      create(:field_with_displays, field: 'site_id', tablename: 'mega_bar_site_joins', model_display_ids: model_model_display_ids) 
      create(:field_with_displays, field: 'siteable_id', tablename: 'mega_bar_site_joins', model_display_ids: model_model_display_ids) 
      create(:field_with_displays, field: 'siteable_type', tablename: 'mega_bar_site_joins', model_display_ids: model_model_display_ids) 
    }
    # Megabar says, If you want to test invalid data, modify these: 
    let(:skip_invalids) { false }
    let(:invalid_new) { {site_id: ''} }
    let(:invalid_attributes) {
      f = build(:site_join)
      { site_id: '' }
    }
    let(:controlller) { 'mega_bar/site_joins' } #might need editing!

    # the rest of these you shouldn't have to mess with.
    let(:controller_class) { MegaBar::SiteJoinsController }
    let(:model_class) { MegaBar::SiteJoin }
    
    let(:model_and_page) { create(:model_with_page, classname: 'SiteJoin', tablename: 'mega_bar_site_joins', name: 'SiteJoin', modyule: 'MegaBar' ) }
    let(:page_terms) { ["MegaBar", "site-joins"]  }
    let(:page_name) { 'MegaBar page'   }
    let(:spec_subject) { 'site_join' }
    let(:uri) { 'site-joins' }
    let(:valid_session) { {} }
    let(:a_record) {
      create(:site_join) unless model_class.first
      model_class.first
    }

  end
end
