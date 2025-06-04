module MegaBar
  class Textread < ActiveRecord::Base
    validates_presence_of :field_display_id
    validates_uniqueness_of :field_display_id
    scope :by_field_display_id, ->(field_display_id) { where(field_display_id: field_display_id)}

    before_create :set_deterministic_id

    # Deterministic ID generation for Textreads
    # ID range: 24000-24999
    def self.deterministic_id(field_display_id)
      # Use field_display_id to create unique identifier
      identifier = "textread_#{field_display_id}"
      hash = Digest::MD5.hexdigest(identifier)
      base_id = 24000 + (hash.to_i(16) % 1000)
      
      # Check for collisions and increment if needed
      while MegaBar::Textread.exists?(id: base_id)
        base_id += 1
        break if base_id >= 25000  # Don't overflow into next range
      end
      
      base_id
    end

    def get_model_id
      6
    end
    def controller_name
      'mega_bar/textreads'
    end

    private

    def set_deterministic_id
      unless self.id
        self.id = self.class.deterministic_id(self.field_display_id)
      end
    end
  end
end
