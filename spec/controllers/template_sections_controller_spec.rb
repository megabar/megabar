module MegaBar
  require 'spec_helper'
  require_relative 'common'
  RSpec.describe MegaBar::TemplateSectionsController, :type => :controller do
    include_context "common" #pretty important!

    # MEGABAR almost gets you started with testing.. 
    # After you add a field, manually add that field to these:
    # ALSO, don't forget to add your fields manually to your factory in /spec/factories/template_section
    let(:updated_attrs) { { 'tbd' => 'tbd' } }
    let(:valid_attributes) {{ 'tbd' => "tbd" } }
    let(:valid_new) { { tbd: 'tbd'} }
    let(:fields_and_displays) {  create(:field_with_displays, field: 'tbd', tablename: 'mega_bar_template_sections', model_display_ids: model_model_display_ids) }
    # Megabar says, If you want to test invalid data, modify these: 
    let(:skip_invalids) { true }
    let(:invalid_new) { {tbd: ''} }
    let(:invalid_attributes) {
      f = build(:template_section)
      { tbd: f[:tbd] }
    }
    let(:controlller) { 'template_sections' } #might need editing!

    # the rest of these you shouldn't have to mess with.
    let(:controller_class) { MegaBar::TemplateSectionsController }
    let(:model_class) { MegaBar::TemplateSection }
    
    let(:model_and_page) { create(:model_with_page, classname: 'TemplateSection', tablename: 'mega_bar_template_sections', name: 'TemplateSection', modyule: 'MegaBar' ) }
    let(:page_terms) { ["MegaBar", "template-sections"]  }
    let(:page_name) { 'MegaBar page'   }
    let(:spec_subject) { 'template_section' }
    let(:uri) { 'template-sections' }
    let(:valid_session) { {} }
    let(:a_record) {
      create(:template_section) unless model_class.first
      model_class.first
    }

  end
end