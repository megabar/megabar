module MegaBar 
  class TmpPage < ActiveRecord::Base
    validates_uniqueness_of :path, message: 'page oops'
  end
end 
