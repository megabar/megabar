require 'spec_helper'
module MegaBar
  describe Model, :type => :model do
    it 'has a valid factory' do
      Model.skip_callback("create",:after,:make_model_displays)
      Model.skip_callback("create",:after,:make_all_files)
      expect(FactoryGirl.create(:model)).to be_valid
    end
  end
end
