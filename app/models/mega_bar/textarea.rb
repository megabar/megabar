module MegaBar
  class Textarea < ActiveRecord::Base
    self.table_name = "mega_bar_textareas"
    scope :by_field_display_id, ->(field_display_id) { where(field_display_id: field_display_id)}
    def get_model_id
      # tbd
    end
  end
end