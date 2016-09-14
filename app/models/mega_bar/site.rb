module MegaBar 
  class Site < ActiveRecord::Base
    belongs_to :portfolio
    belongs_to :themes
    belongs_to :site_joins, polymorphic: true
    has_many :site_joins
    has_many :layouts, through: :site_joins, source: :siteable, source_type: 'Layout'
    has_many :blocks, through: :site_joins, source: :siteable, source_type: 'Block'    
    validates_uniqueness_of :code_name
    validates_presence_of :code_name, allow_blank: false
    validates_presence_of :portfolio_id, allow_blank: false
    validates_presence_of :theme_id, allow_blank: false
    validates_presence_of :name, allow_blank: false

  end
end 
