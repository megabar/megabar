module MegaBar
  class Option < ActiveRecord::Base
    validates_presence_of :text, :value, :field_id
    validates_uniqueness_of :value, scope: :field_id,  message: "dupe option for this field"
    before_create :set_deterministic_id

    # Deterministic ID generation for Options
    # ID range: 8000-8999
    def self.deterministic_id(field_id, text, value)
      # Use field_id, text, and value to create unique identifier
      identifier = "#{field_id}_#{text}_#{value}"
      hash = Digest::MD5.hexdigest(identifier)
      base_id = 8000 + (hash.to_i(16) % 1000)
      
      # Check for collisions and increment if needed
      while MegaBar::Option.exists?(id: base_id)
        base_id += 1
        break if base_id >= 9000  # Don't overflow into next range
      end
      
      base_id
    end

    private

    def set_deterministic_id
      # Only set deterministic ID if not already set
      unless self.id
        self.id = self.class.deterministic_id(self.field_id, self.text, self.value)
      end
    end

  end
end
