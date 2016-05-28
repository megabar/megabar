module MegaBar
  class TmpTextread < ActiveRecord::Base
    validates_uniqueness_of :field_display_id, message: 'textread oops'
  end
end
