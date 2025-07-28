require 'spec_helper'
require_relative 'shared_examples/megabar_controller_structure'

module MegaBar
  RSpec.describe TextreadsController, type: :controller do
    include_examples "crud_controller", "Textread"

    describe "Textreads Controller Specifics" do
      it "supports new functionality" do
      expect(described_class.instance_methods).to include(:new)
    end

    end
  end
end
