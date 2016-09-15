module MegaBar 
  class SiteJoin < ActiveRecord::Base
    belongs_to :siteable, polymorphic: true #, optional: true
    belongs_to :site
    validates_presence_of :siteable_type, allow_blank: false
  end
end 
