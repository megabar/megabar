module MegaBar
  class Select < ActiveRecord::Base
    self.table_name = "mega_bar_selects"
    scope :by_field_display_id, ->(field_display_id) { where(field_display_id: field_display_id)}
    def get_model_id
      8
    end
  end
end