module MegaBar
  class TmpField < ActiveRecord::Base 
    validates_uniqueness_of :field, scope: :model_id,  message: "dupe field for this model"
  end
end
