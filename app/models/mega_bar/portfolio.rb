module MegaBar 
  class Portfolio < ActiveRecord::Base
    has_many :sites
    belongs_to :theme
    validates_uniqueness_of :code_name
    validates_presence_of :code_name
  end
end 
