module MegaBar 
  class SiteJoin < ActiveRecord::Base
    belongs_to :siteable, polymorphic: true
    belongs_to :site
    validates_presence_of :site_id, allow_blank: false
    validates_presence_of :siteable_id, allow_blank: false
    validates_presence_of :siteable_type, allow_blank: false
  end
end 
