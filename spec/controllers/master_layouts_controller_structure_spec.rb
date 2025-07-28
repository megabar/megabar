require 'spec_helper'
require_relative 'shared_examples/megabar_controller_structure'

module MegaBar
  RSpec.describe MasterLayoutsController, type: :controller do
    include_examples "special_controller"

    describe "MasterLayouts Controller Specifics" do
      it "supports render layout with sections functionality" do
      expect(described_class.instance_methods).to include(:render_layout_with_sections)
    end

    end
  end
end
