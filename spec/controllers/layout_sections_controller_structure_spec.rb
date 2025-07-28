require 'spec_helper'
require_relative 'shared_examples/megabar_controller_structure'

module MegaBar
  RSpec.describe LayoutSectionsController, type: :controller do
    include_examples "crud_controller", "LayoutSection"
  end
end
