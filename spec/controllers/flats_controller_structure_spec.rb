require 'spec_helper'
require_relative 'shared_examples/megabar_controller_structure'

module MegaBar
  RSpec.describe FlatsController, type: :controller do
    include_examples "special_controller"

    describe "Flats Controller Specifics" do
      it "supports index functionality" do
      expect(described_class.instance_methods).to include(:index)
    end

    end
  end
end
