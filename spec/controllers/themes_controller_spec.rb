module MegaBar
  require 'spec_helper'
  require_relative 'common'
  RSpec.describe MegaBar::ThemesController, :type => :controller do
    include_context "common" #pretty important!

    # MEGABAR almost gets you started with testing.. 
    # After you add a field, manually add that field to these:
    # ALSO, don't forget to add your fields manually to your factory in /spec/factories/theme
    let(:updated_attrs) { { 'name' => 'New Name', 'code_name' => 'code_name' } }
    let(:valid_attributes) {{ 'name' => "New Name", 'code_name' => 'code_name' } }
    let(:valid_new) { { name: 'Name', code_name: 'code_name'} }
    let(:fields_and_displays) {  
      create(:field_with_displays, field: 'name', tablename: 'mega_bar_themes', model_display_ids: model_model_display_ids) 
      create(:field_with_displays, field: 'code_name', tablename: 'mega_bar_themes', model_display_ids: model_model_display_ids) 
    }
   
    # Megabar says, If you want to test invalid data, modify these: 
    let(:skip_invalids) { false }
    let(:invalid_new) { {name: ''} }
    let(:invalid_attributes) {
      f = build(:theme)
      { name: '' }
    }
    let(:controlller) { 'mega_bar/themes' } #might need editing!

    # the rest of these you shouldn't have to mess with.
    let(:controller_class) { MegaBar::ThemesController }
    let(:model_class) { MegaBar::Theme }
    
    let(:model_and_page) { create(:model_with_page, classname: 'Theme', tablename: 'mega_bar_themes', name: 'Theme', modyule: 'MegaBar' ) }
    let(:page_terms) { ["MegaBar", "themes"]  }
    let(:page_name) { 'MegaBar page' }
    let(:spec_subject) { 'theme' }
    let(:uri) { 'themes' }
    let(:valid_session) { {} }
    let(:a_record) {
      create(:theme) unless model_class.first
      model_class.first
    }

  end
end
