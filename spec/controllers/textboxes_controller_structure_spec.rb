require 'spec_helper'
require_relative 'shared_examples/megabar_controller_structure'

module MegaBar
  RSpec.describe TextboxesController, type: :controller do
    include_examples "crud_controller", "Textbox"
    
    describe "Textboxes Controller Specifics" do
      it "supports new functionality" do
      expect(described_class.instance_methods).to include(:new)
    end
      
      it "properly inherits from ApplicationController" do
        expect(described_class.superclass).to eq(ApplicationController)
      end
    end
  end
end 