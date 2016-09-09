module MegaBar 
  class Theme < ActiveRecord::Base
    has_many :sites
  end
end 
