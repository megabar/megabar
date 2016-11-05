module MegaBar
  require 'spec_helper'
  require_relative 'common'
  RSpec.describe MegaBar::ThemeJoinsController, :type => :controller do
    include_context "common" #pretty important!

    # MEGABAR almost gets you started with testing.. 
    # After you add a field, manually add that field to these:
    # ALSO, don't forget to add your fields manually to your factory in /spec/factories/theme_join
    let(:updated_attrs) { {  'theme_id' => 1, 'themeable_id' => 1, 'themeable_type' => 'MegaBar::Block' } }
    let(:valid_attributes) {{ 'theme_id' => '1', 'themeable_id' => '1', 'themeable_type' => 'MegaBar::Block'  } }
    let(:valid_new) { { 'theme_id' => '1', 'themeable_id' => '1', 'themeable_type' => 'MegaBar::Layout' } }
    let(:fields_and_displays) {  
      create(:field_with_displays, field: 'theme_id', tablename: 'mega_bar_theme_joins', model_display_ids: model_model_display_ids) 
      create(:field_with_displays, field: 'themeable_id', tablename: 'mega_bar_theme_joins', model_display_ids: model_model_display_ids) 
      create(:field_with_displays, field: 'themeable_type', tablename: 'mega_bar_theme_joins', model_display_ids: model_model_display_ids) 
    }
    # Megabar says, If you want to test invalid data, modify these: 
    let(:skip_invalids) { false }
    let(:invalid_new) { {theme_id: ''} }
    let(:invalid_attributes) {
      f = build(:theme_join)
      { theme_id: '' }
    }
    let(:controlller) { 'mega_bar/theme_joins' } #might need editing!

    # the rest of these you shouldn't have to mess with.
    let(:controller_class) { MegaBar::ThemeJoinsController }
    let(:model_class) { MegaBar::ThemeJoin }
    
    let(:model_and_page) { create(:model_with_page, classname: 'ThemeJoin', tablename: 'mega_bar_theme_joins', name: 'ThemeJoin', modyule: 'MegaBar' ) }
    let(:page_terms) { ["MegaBar", "theme-joins"]  }
    let(:page_name) { 'MegaBar page'   }
    let(:spec_subject) { 'theme_join' }
    let(:uri) { 'theme-joins' }
    let(:valid_session) { {} }
    let(:a_record) {
      create(:theme_join) unless model_class.first
      model_class.first
    }

  end
end
