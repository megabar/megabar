module MegaBar 
  class ThemeJoin < ActiveRecord::Base
    belongs_to :themeable, polymorphic: true #, optional: true
    belongs_to :theme
    validates_presence_of :themeable_type, allow_blank: false
  end
end 
