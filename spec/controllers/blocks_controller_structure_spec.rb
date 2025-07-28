require 'spec_helper'
require_relative 'shared_examples/megabar_controller_structure'

module MegaBar
  RSpec.describe BlocksController, type: :controller do
    include_examples "crud_controller", "Block"

    describe "Blocks Controller Specifics" do
      it "includes MegaBar functionality" do
        expect(described_class.included_modules).to include(MegaBar::MegaBarConcern)
      end

      it "can handle block administration" do
        expect(described_class.instance_methods).to include(:new)
        expect(described_class.instance_methods).to include(:edit)
      end

    end
  end
end
