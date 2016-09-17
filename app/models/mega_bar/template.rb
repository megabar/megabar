module MegaBar 
  class Template < ActiveRecord::Base
    has_many :template_sections
  end
end 
