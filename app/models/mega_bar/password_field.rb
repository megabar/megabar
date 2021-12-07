module MegaBar
  class PasswordField < ActiveRecord::Base
    validates_presence_of :field_display_id
    validates_uniqueness_of :field_display_id
    scope :by_field_display_id, ->(field_display_id) { where(field_display_id: field_display_id)}
    def get_model_id
      27
    end
    def controller_name
      'mega_bar/password_fields'
    end

  end
end 
