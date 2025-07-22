require 'spec_helper'
module MegaBar
  describe Field, :type => :model do
    before(:each) do
      # Skip callbacks that might interfere with factory creation
      MegaBar::Field.skip_callback("create",:after,:make_field_displays) rescue nil
      MegaBar::Field.skip_callback("create",:after,:make_migration) rescue nil
      MegaBar::Field.skip_callback("save",:after,:make_field_displays) rescue nil
    end
    
    after(:each) do
      # Re-enable callbacks for other tests
      MegaBar::Field.set_callback("create",:after,:make_field_displays) rescue nil
      MegaBar::Field.set_callback("create",:after,:make_migration) rescue nil
      MegaBar::Field.set_callback("save",:after,:make_field_displays) rescue nil
    end
    
    it 'has a valid factory' do
      expect(FactoryBot.create(:field)).to be_valid
    end
  end
end
