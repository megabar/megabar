module MegaBar 
  class Site < ActiveRecord::Base
    belongs_to :portfolio
    belongs_to :theme
  end
end 
