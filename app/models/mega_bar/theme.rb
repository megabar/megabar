module MegaBar
  class Theme < ActiveRecord::Base
    has_many :sites
    has_many :portfolios

    # belongs_to :themeable, polymorphic: true
    has_many :theme_joins
    has_many :layouts, through: :theme_joins, source: :themeable, source_type: 'Layout'
    has_many :blocks, through: :theme_joins, source: :themeable, source_type: 'Block'
    validates_uniqueness_of :code_name
    validates_presence_of :code_name, allow_blank: false
    validates_presence_of :name, allow_blank: false
  end
end
