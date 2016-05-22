module MegaBar 
  class TmpLayout < ActiveRecord::Base
    validates_uniqueness_of :name, scope: :page_id,  message: "dupe layout name for this page"
  end
end 
