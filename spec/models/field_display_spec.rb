require 'spec_helper'
module MegaBar
  describe FieldDisplay, :type => :model do
    it 'has a valid factory' do
      expect(FactoryGirl.create(:field_display)).to be_valid
    end
  end
end
