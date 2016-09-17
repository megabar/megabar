module MegaBar 
  class Layable < ActiveRecord::Base
    belongs_to :layout
    belongs_to :layout_section
    has_one :template_section
  end
end 
