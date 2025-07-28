require 'spec_helper'
require_relative 'shared_examples/megabar_controller_structure'

module MegaBar
  RSpec.describe MasterPagesController, type: :controller do
    include_examples "special_controller"
    
    describe "Master Pages Controller Specifics" do
      it "supports render page functionality" do
      expect(described_class.instance_methods).to include(:render_page)
    end
      
      it "includes authorization helpers" do
        expect(described_class._helpers.included_modules.map(&:to_s)).to include("MegaBar::AuthorizationHelper")
      end
    end
  end
end 