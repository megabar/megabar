require 'spec_helper'
require_relative 'shared_examples/megabar_controller_structure'

module MegaBar
  RSpec.describe ModelDisplaysController, type: :controller do
    include_examples "crud_controller", "ModelDisplay"

    describe "ModelDisplays Controller Specifics" do
      it "supports get options functionality" do
      expect(described_class.instance_methods).to include(:get_options)
    end

    end
  end
end
