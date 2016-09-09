module MegaBar
  require 'spec_helper'
  require_relative 'common'
  RSpec.describe MegaBar::PortfoliosController, :type => :controller do
    include_context "common" #pretty important!

    # MEGABAR almost gets you started with testing.. 
    # After you add a field, manually add that field to these:
    # ALSO, don't forget to add your fields manually to your factory in /spec/factories/portfolio
    let(:updated_attrs) { { 'tbd' => 'tbd' } }
    let(:valid_attributes) {{ 'tbd' => "tbd" } }
    let(:valid_new) { { tbd: 'tbd'} }
    let(:fields_and_displays) {  create(:field_with_displays, field: 'tbd', tablename: 'mega_bar_portfolios', model_display_ids: model_model_display_ids) }
    # Megabar says, If you want to test invalid data, modify these: 
    let(:skip_invalids) { true }
    let(:invalid_new) { {tbd: ''} }
    let(:invalid_attributes) {
      f = build(:portfolio)
      { tbd: f[:tbd] }
    }
    let(:controlller) { 'portfolios' } #might need editing!

    # the rest of these you shouldn't have to mess with.
    let(:controller_class) { MegaBar::PortfoliosController }
    let(:model_class) { MegaBar::Portfolio }
    
    let(:model_and_page) { create(:model_with_page, classname: 'Portfolio', tablename: 'mega_bar_portfolios', name: 'Portfolio', modyule: 'MegaBar' ) }
    let(:page_terms) { ["MegaBar", "portfolios"]  }
    let(:page_name) { 'MegaBar page'   }
    let(:spec_subject) { 'portfolio' }
    let(:uri) { 'portfolios' }
    let(:valid_session) { {} }
    let(:a_record) {
      create(:portfolio) unless model_class.first
      model_class.first
    }

  end
end
