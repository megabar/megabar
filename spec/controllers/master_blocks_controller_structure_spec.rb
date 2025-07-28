require 'spec_helper'
require_relative 'shared_examples/megabar_controller_structure'

module MegaBar
  RSpec.describe MasterBlocksController, type: :controller do
    include_examples "special_controller"

    describe "MasterBlocks Controller Specifics" do
      it "supports render flat html block functionality" do
      expect(described_class.instance_methods).to include(:render_flat_html_block)
    end

    end
  end
end
