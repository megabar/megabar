module MegaBar
  require 'spec_helper'


  RSpec.describe MegaBar::::TextareasController, :type => :controller do
    include_context "common" #pretty important!

    # MEGABAR almost gets you started with testing.. 
    # After you add a field, manually add that field to these:
    # ALSO, don't forget to add your fields manually to your factory in /spec/factories/textarea
    let(:updated_attrs) { { 'tbd' => 'tbd' } }
    let(:valid_attributes) {{ 'tbd' => "tbd" } }
    let(:valid_new) { { tbd: 'tbd'} }
    let(:fields_and_displays) {  create(:field_with_displays, field: 'tbd', tablename: 'mega_bar_textareas') }
    # Megabar says, If you want to test invalid data, modify these: 
    let(:skip_invalids) { true }
    let(:invalid_new) { {tbd: ''} }
    let(:invalid_attributes) {
      f = build(:textarea)
      { tbd: f[:tbd] }
    }

    # the rest of these you shouldn't have to mess with.
    let(:controller_class) { MegaBar::TextareasController }
    let(:model_class) { MegaBar::Textarea }
    let(:controlller) { 'textareas' }
    let(:model_and_page) { create(:model_with_page, classname: 'Textarea', tablename: 'mega_bar_textareas', name: 'Textarea', modyule: 'MegaBar' ) }
    let(:page_terms) { ["MegaBar", "textareas"]  }
    let(:page_name) { 'MegaBar page'   }
    let(:spec_subject) { 'textarea' }
    let(:uri) { 'textareas' }
    let(:valid_session) { {} }
    let(:a_record) {
      create(:textarea) unless model_class.first
      model_class.first
    }

  end
end
