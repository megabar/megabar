require 'spec_helper'
require_relative 'shared_examples/megabar_controller_structure'

module MegaBar
  RSpec.describe RootsController, type: :controller do
    include_examples "special_controller"

    describe "Roots Controller Specifics" do
      it "supports root page functionality" do
      expect(described_class.instance_methods).to include(:root_page)
    end

    end
  end
end
