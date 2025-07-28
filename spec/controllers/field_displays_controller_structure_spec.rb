require 'spec_helper'
require_relative 'shared_examples/megabar_controller_structure'

module MegaBar
  RSpec.describe FieldDisplaysController, type: :controller do
    include_examples "crud_controller", "FieldDisplay"
    
    describe "Field Displays Controller Specifics" do
      it "properly inherits from ApplicationController" do
        expect(described_class.superclass).to eq(ApplicationController)
      end
    end
  end
end 