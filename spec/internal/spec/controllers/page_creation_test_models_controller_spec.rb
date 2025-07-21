module MegaBar
  require 'spec_helper'
  
  
  RSpec.describe MegaBar::PageCreationTestModelsController, :type => :controller do
    
    
    describe "PageCreationTestModel Controller Specifics" do
      it "supports custom functionality" do
        expect(described_class).to be_a(Class)
        expect(described_class.included_modules).to include(MegaBar::MegaBarConcern)
      end
    end
  end
end
