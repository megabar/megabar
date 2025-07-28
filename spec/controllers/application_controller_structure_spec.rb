require 'spec_helper'
require_relative 'shared_examples/megabar_controller_structure'

module MegaBar
  RSpec.describe ApplicationController, type: :controller do
    include_examples "basic_megabar_controller"
    
    describe "Application Controller Specifics" do
      it "inherits from ActionController::Base" do
        expect(described_class.superclass).to eq(ActionController::Base)
      end
      
      it "supports to s functionality" do
      expect(described_class.instance_methods).to include(:to_s)
    end
      
      it "includes authorization helper" do
        expect(described_class._helpers.included_modules.map(&:to_s)).to include("MegaBar::AuthorizationHelper")
      end
    end
  end
end 