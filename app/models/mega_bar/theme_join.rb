module MegaBar 
  class ThemeJoin < ActiveRecord::Base
    belongs_to :themeable, polymorphic: true
    belongs_to :theme
  end
end 
