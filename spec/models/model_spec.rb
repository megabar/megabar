require 'spec_helper'
module MegaBar
  describe Model, :type => :model do
    it 'has a valid factory' do
      expect(FactoryGirl.create(:model)).to be_valid
    end
  end
end
