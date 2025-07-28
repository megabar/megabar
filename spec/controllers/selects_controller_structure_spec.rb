require 'spec_helper'
require_relative 'shared_examples/megabar_controller_structure'

module MegaBar
  RSpec.describe SelectsController, type: :controller do
    include_examples "crud_controller", "Select"
  end
end
