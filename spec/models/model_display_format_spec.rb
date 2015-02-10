require 'spec_helper'
module MegaBar
  describe ModelDisplayFormat, :type => :model do
    it 'has a valid factory' do
      expect(FactoryGirl.create(:model_display_format)).to be_valid
    end
  end
end
