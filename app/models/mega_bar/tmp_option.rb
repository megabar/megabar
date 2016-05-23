module MegaBar 
  class TmpOption < ActiveRecord::Base
    validates_uniqueness_of :value, scope: :field_id,  message: "dupe option for this field"
  end
end 
