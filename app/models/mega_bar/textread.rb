module MegaBar
  class Textread < ActiveRecord::Base
    scope :by_field_display_id, ->(field_display_id) { where(field_display_id: field_display_id)}
    def get_model_id
      7
    end

  end
end