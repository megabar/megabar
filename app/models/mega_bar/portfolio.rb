module MegaBar
  class Portfolio < ActiveRecord::Base
    has_many :sites
    belongs_to :theme
    validates_uniqueness_of :code_name
    validates_presence_of :code_name, allow_blank: false
    validates_presence_of :name, allow_blank: false
    validates_presence_of :theme_id, allow_blank: false
  end
end
