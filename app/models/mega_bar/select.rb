module MegaBar
  class Select < ActiveRecord::Base
    scope :by_field_display_id, ->(field_display_id) { where(field_display_id: field_display_id)}
    def get_model_id
      14
    end
  end
end