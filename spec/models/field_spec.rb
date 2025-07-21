require 'spec_helper'
module MegaBar
  describe Field, :type => :model do
    it 'has a valid factory' do
      # Skip callbacks that might interfere with factory creation
      MegaBar::Field.skip_callback("create",:after,:make_field_displays) rescue nil
      MegaBar::Field.skip_callback("create",:after,:make_migration) rescue nil
      MegaBar::Field.skip_callback("save",:after,:make_field_displays) rescue nil
      expect(FactoryBot.create(:field)).to be_valid
    end
  end
end
