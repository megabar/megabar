require 'spec_helper'
module MegaBar
  describe Textread, :type => :model do
    it 'has a valid factory' do
      expect(FactoryBot.create(:textread)).to be_valid
    end
  end
end
