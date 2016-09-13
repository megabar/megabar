module MegaBar 
  class Theme < ActiveRecord::Base
    has_many :sites
    belongs_to :theme_joins, polymorphic: true
    has_many :theme_joins
    has_many :layouts, through: :theme_joins, source: :themeable, source_type: 'Layout'
    has_many :blocks, through: :theme_joins, source: :themeable, source_type: 'Block'

  end
end 
