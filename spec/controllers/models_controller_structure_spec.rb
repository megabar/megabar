require 'spec_helper'
require_relative 'shared_examples/megabar_controller_structure'

module MegaBar
  RSpec.describe ModelsController, type: :controller do
    include_examples "crud_controller", "Model"
    
    describe "Models Controller Specifics" do
      it "supports index functionality" do
      expect(described_class.instance_methods).to include(:index)
    end
    end
  end
end 