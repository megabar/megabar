require 'spec_helper'
require_relative 'shared_examples/megabar_controller_structure'

module MegaBar
  RSpec.describe MegaDashesController, type: :controller do
    include_examples "special_controller"

    describe "MegaDashes Controller Specifics" do
      it "supports dashboards init functionality" do
      expect(described_class.instance_methods).to include(:dashboards_init)
    end

    end
  end
end
