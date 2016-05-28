module MegaBar 
  class TmpModelDisplayFormat < ActiveRecord::Base
    validates_uniqueness_of :name, message: 'model display format oops'
  end
end 
