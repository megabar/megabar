#MegaBar::TemplateSection(id: integer, created_at: datetime, updated_at: datetime, position: integer, name: string, code_name: string, template_id: integer)
module MegaBar
  require 'spec_helper'
  require_relative 'common'
  RSpec.describe MegaBar::TemplateSectionsController, :type => :controller do
    include_context "common" #pretty important!

    # MEGABAR almost gets you started with testing..
    # After you add a field, manually add that field to these:
    # ALSO, don't forget to add your fields manually to your factory in /spec/factories/template_section
    let(:updated_attrs) { { 'name' => 'valid template name', 'code_name' => 'valid_code_name', 'template_id' => 1  } }
    let(:valid_attributes) { { 'name' => 'valid template name', 'code_name' => 'valid_code_name', 'template_id' => '1'  }}
    let(:valid_new) { { 'name' => 'valid new template name', 'code_name' => 'valid_new_code_name', 'template_id' => '1'  } }
    let(:fields_and_displays) {
      create(:field_with_displays, field: 'name', tablename: 'mega_bar_template_sections', model_display_ids: model_model_display_ids)
      create(:field_with_displays, field: 'code_name', tablename: 'mega_bar_template_sections', model_display_ids: model_model_display_ids)
      create(:field_with_displays, field: 'template_id', tablename: 'mega_bar_template_sections', model_display_ids: model_model_display_ids)
    } # Megabar says, If you want to test invalid data, modify these:
    let(:skip_invalids) { false }
    let(:invalid_new) { {'Name': ''} }
    let(:invalid_attributes) {
      f = build(:template_section)
      { name: f[:Name], template_id: nil, code_name: '' }
    }
    let(:controlller) { 'mega_bar/template_sections' } #might need editing!

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
