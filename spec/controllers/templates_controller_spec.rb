module MegaBar
  require 'spec_helper'
  require_relative 'common'
  RSpec.describe MegaBar::TemplatesController, :type => :controller do
    include_context "common" #pretty important!

    # MEGABAR almost gets you started with testing.. 
    # After you add a field, manually add that field to these:
    # ALSO, don't forget to add your fields manually to your factory in /spec/factories/template
    let(:updated_attrs) { { 'tbd' => 'tbd' } }
    let(:valid_attributes) {{ 'tbd' => "tbd" } }
    let(:valid_new) { { tbd: 'tbd'} }
    let(:fields_and_displays) {  create(:field_with_displays, field: 'tbd', tablename: 'mega_bar_templates', model_display_ids: model_model_display_ids) }
    # Megabar says, If you want to test invalid data, modify these: 
    let(:skip_invalids) { true }
    let(:invalid_new) { {tbd: ''} }
    let(:invalid_attributes) {
      f = build(:template)
      { tbd: f[:tbd] }
    }
    let(:controlller) { 'templates' } #might need editing!

    # the rest of these you shouldn't have to mess with.
    let(:controller_class) { MegaBar::TemplatesController }
    let(:model_class) { MegaBar::Template }
    
    let(:model_and_page) { create(:model_with_page, classname: 'Template', tablename: 'mega_bar_templates', name: 'Template', modyule: 'MegaBar' ) }
    let(:page_terms) { ["MegaBar", "templates"]  }
    let(:page_name) { 'MegaBar page'   }
    let(:spec_subject) { 'template' }
    let(:uri) { 'templates' }
    let(:valid_session) { {} }
    let(:a_record) {
      create(:template) unless model_class.first
      model_class.first
    }

  end
end
