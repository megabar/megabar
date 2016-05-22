module MegaBar
  class TmpTextbox < ActiveRecord::Base
    validates_uniqueness_of :field_display_id, message: 'textbox oops'
  end
end
