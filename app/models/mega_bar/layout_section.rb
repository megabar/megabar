module MegaBar 
  class LayoutSection < ActiveRecord::Base
    attr_accessor :template_section_id
   
    has_many :layables
    has_many :layouts, through: :layables
    has_many :blocks
  end
end 
