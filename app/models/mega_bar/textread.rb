module MegaBar
  class Textread < ActiveRecord::Base
    belongs_to :field_displays
    scope :by_field_display_id, ->(field_display_id) { where(field_display_id: field_display_id)}
  end
end