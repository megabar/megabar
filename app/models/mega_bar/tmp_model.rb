module MegaBar
  class TmpModel < ActiveRecord::Base
    validates_uniqueness_of :classname, message: 'model ooops'  
  end
end
