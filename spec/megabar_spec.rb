require 'spec_helper'

class MegabarTest < ActiveSupport::TestCase
  binding.pry
  test "truth" do
    assert_kind_of Module, MegaBar
  end
end
