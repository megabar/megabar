
module MegaBar
  require_relative 'common'
  require 'spec_helper'

  RSpec.describe MegaBar::PagesController, :type => :controller do

    include_context "common" #pretty important!
    let(:controller_class) { MegaBar::PagesController }
    let(:model_class) { MegaBar::Page }
    let(:controlller) { 'mega_bar/pages' }
    let(:invalid_new) { {make_page: ''} }
    let(:page_name) { 'Page Page' }
    let(:page_terms) { ['mega-bar', 'pages'] }
    let(:spec_subject) { 'page' }
    let(:updated_attrs) { { 'name' => 'testing' } }
    let(:uri) { '/mega-bar/pages' }

    let(:valid_new) { { name: 'new page', path: '/new-page', make_layout_and_block: ''} }

    let(:valid_session) { {} }

    let(:model_and_page) { create(:model_with_page, classname: 'Page', tablename: 'mega_bar_pages', name: 'Pages') }

    let(:fields_and_displays) { #have to at least have the required model fields.
      create(:field_with_displays, tablename: 'mega_bar_layouts')
      create(:field_with_displays, field: 'name' )
      create(:field_with_displays, field: 'path')
    }
    let(:a_record) {
      model_class.first
    }



    let(:valid_attributes) {
      { name: 'testing', path: '/updated_path'  }
    }
    let(:invalid_attributes) {
      m = build(:page)
      { name: ''  }
    }


    let(:valid_session) { {} }
  end

end
