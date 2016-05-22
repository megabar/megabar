module MegaBar 
  class ModelDisplayFormat < ActiveRecord::Base
    validates_uniqueness_of :name
  end
end
