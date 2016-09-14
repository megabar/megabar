module MegaBar 
  class ThemeJoin < ActiveRecord::Base
    belongs_to :themeable, polymorphic: true
    belongs_to :theme
    validates_presence_of :theme_id, allow_blank: false
    validates_presence_of :themeable_id, allow_blank: false
    validates_presence_of :themeable_type, allow_blank: false
  end
end 
