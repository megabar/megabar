module MegaBar 
  class SiteJoin < ActiveRecord::Base
    belongs_to :siteable, polymorphic: true
    belongs_to :site
  end
end 
