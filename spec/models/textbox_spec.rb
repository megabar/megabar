require 'spec_helper'
module MegaBar
  describe Textbox, :type => :model do
    it 'has a valid factory' do
      expect(FactoryGirl.create(:textbox)).to be_valid
    end
  end
end
