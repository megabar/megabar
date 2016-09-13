module MegaBar 
  class Site < ActiveRecord::Base
    belongs_to :portfolio
    belongs_to :themes
    belongs_to :site_joins, polymorphic: true
    has_many :site_joins
    has_many :layouts, through: :site_joins, source: :siteable, source_type: 'Layout'
    has_many :blocks, through: :site_joins, source: :siteable, source_type: 'Block'
    

  end
end 
