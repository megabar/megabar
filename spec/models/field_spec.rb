require 'spec_helper'
module MegaBar
  describe Field, :type => :model do
    it 'has a valid factory' do
      expect(FactoryGirl.create(:field)).to be_valid
    end
  end
end
