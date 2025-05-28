module MegaBar
  class Date < ActiveRecord::Base
    validates_presence_of :field_display_id
    scope :by_field_display_id, ->(field_display_id) { where(field_display_id: field_display_id)}
    validates_uniqueness_of :field_display_id
    def controller_name
      'mega_bar/dates'
    end

    def get_model_id
      29
    end
  end
end 
