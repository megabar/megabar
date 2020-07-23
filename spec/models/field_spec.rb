require 'spec_helper'
module MegaBar
  describe Field, :type => :model do
    it 'has a valid factory' do
      MegaBar::Field.skip_callback("create",:after,:make_field_displays)
      MegaBar::Field.skip_callback("create",:after,:make_migration)
	  MegaBar::Field.skip_callback("save",:after,:make_field_displays)
      expect(FactoryBot.create(:field)).to be_valid
    end
  end
end
