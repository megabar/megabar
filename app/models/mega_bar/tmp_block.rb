module MegaBar 
  class TmpBlock < ActiveRecord::Base
    validates_uniqueness_of :name, scope: :layout_id, message: "block oops"
  end
end 
