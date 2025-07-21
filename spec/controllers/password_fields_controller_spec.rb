module MegaBar
  require 'spec_helper'
  require_relative 'common'
  RSpec.describe MegaBar::PasswordFieldsController, :type => :controller do
    it "can be instantiated" do
      expect(MegaBar::PasswordFieldsController).to be_a(Class)
    end

    it "inherits from ApplicationController" do
      expect(MegaBar::PasswordFieldsController.superclass).to eq(MegaBar::ApplicationController)
    end

    include_context "common" #pretty important!

    # MEGABAR almost gets you started with testing.. 
    # After you add a field, manually add that field to these:
    # ALSO, don't forget to add your fields manually to your factory in /spec/factories/password_field
    let(:updated_attrs) { { 'tbd' => 'tbd' } }
    let(:valid_attributes) {{ 'tbd' => "tbd" } }
    let(:valid_new) { { tbd: 'tbd'} }
    let(:fields_and_displays) {  create(:field_with_displays, field: 'tbd', tablename: 'mega_bar_password_fields', model_display_ids: model_model_display_ids) }
    # Megabar says, If you want to test invalid data, modify these: 
    let(:skip_invalids) { false }
    let(:invalid_new) { { tbd: nil } }
    let(:invalid_attributes) { { 'tbd' => nil } }
    let(:controlller) { 'password_fields' } #might need editing!

    # the rest of these you shouldn't have to mess with.
    let(:controller_class) { MegaBar::PasswordFieldsController }
    let(:model_class) { MegaBar::PasswordField }
    
    let(:model_and_page) { create(:model_with_page, classname: 'PasswordField', tablename: 'mega_bar_password_fields', name: 'PasswordField', modyule: 'MegaBar' ) }
    let(:page_terms) { 'password_fields' }
    let(:page_name) { 'PasswordFields' }
    let(:spec_subject) { 'password_field' }
    let(:uri) { '/mega_bar/password_fields' }
    let(:valid_session) { {} }
    let(:a_record) { model_class.first }

  end
end
