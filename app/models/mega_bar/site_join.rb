module MegaBar 
  class SiteJoin < ActiveRecord::Base
    belongs_to :siteable, polymorphic: true #, optional: true
    belongs_to :site, foreign_key: :siteable_id
    validates_presence_of :siteable_type, allow_blank: false
  end
end 
