require 'spec_helper'
module MegaBar
  describe ModelDisplay, :type => :model do
    it 'has a valid factory' do
      expect(FactoryGirl.create(:model_display)).to be_valid
    end
  end
end
