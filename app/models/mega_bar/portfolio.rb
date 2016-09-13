module MegaBar 
  class Portfolio < ActiveRecord::Base
    has_many :sites
    belongs_to :theme
  end
end 
