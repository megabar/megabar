require 'spec_helper'
require_relative 'shared_examples/megabar_controller_structure'

module MegaBar
  RSpec.describe TemplatesController, type: :controller do
    include_examples "crud_controller", "Template"

    describe "Templates Controller Specifics" do
      it "supports render template with layout sections functionality" do
      expect(described_class.instance_methods).to include(:render_template_with_layout_sections)
    end

    end
  end
end
