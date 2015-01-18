module MegaBar
  class Select < ActiveRecord::Base
    self.table_name = "mega_bar_selects"
    belongs_to :field_displays
 
    scope :by_field_display_id, ->(field_display_id) { where(field_display_id: field_display_id)}
    def get_model_id
      8
    end
  end
end