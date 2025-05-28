module MegaBar
  class PasswordField < ActiveRecord::Base
    validates_presence_of :field_display_id
    validates_uniqueness_of :field_display_id
    scope :by_field_display_id, ->(field_display_id) { where(field_display_id: field_display_id)}

    before_create :set_deterministic_id

    # Deterministic ID generation for PasswordFields
    # ID range: 23000-23999
    def self.deterministic_id(field_display_id)
      # Use field_display_id to create unique identifier
      identifier = "password_field_#{field_display_id}"
      hash = Digest::MD5.hexdigest(identifier)
      base_id = 23000 + (hash.to_i(16) % 1000)
      
      # Check for collisions and increment if needed
      while MegaBar::PasswordField.exists?(id: base_id)
        base_id += 1
        break if base_id >= 24000  # Don't overflow into next range
      end
      
      base_id
    end

    def get_model_id
      27
    end
    def controller_name
      'mega_bar/password_fields'
    end

    private

    def set_deterministic_id
      unless self.id
        self.id = self.class.deterministic_id(self.field_display_id)
      end
    end
  end
end 
