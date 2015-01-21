require 'spec_helper'
module MegaBar
  describe Field, :type => :model do
    it 'has a valid factory' do
      Field.skip_callback("create",:after,:make_field_displays)
      Field.skip_callback("create",:after,:make_migration)
      expect(FactoryGirl.create(:field)).to be_valid
    end
  end
end
