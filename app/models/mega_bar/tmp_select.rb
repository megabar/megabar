module MegaBar
  class TmpSelect < ActiveRecord::Base
    validates_uniqueness_of :field_display_id, message: 'select oops'  
  end
end
