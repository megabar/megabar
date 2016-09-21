module MegaBar 
  class Layable < ActiveRecord::Base
    belongs_to :layout
    belongs_to :layout_section
    belongs_to :template_section
  end
end 
