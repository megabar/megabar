module MegaBar 
  class ModelDisplayFormat < ActiveRecord::Base
    validates_uniqueness_of :name

    before_create :set_deterministic_id

    # Deterministic ID generation for ModelDisplayFormats
    # ID range: 26000-26999
    def self.deterministic_id(name)
      # Use name to create unique identifier
      identifier = "model_display_format_#{name}"
      hash = Digest::MD5.hexdigest(identifier)
      base_id = 26000 + (hash.to_i(16) % 1000)
      
      # Check for collisions and increment if needed
      while MegaBar::ModelDisplayFormat.exists?(id: base_id)
        base_id += 1
        break if base_id >= 27000  # Don't overflow into next range
      end
      
      base_id
    end

    private

    def set_deterministic_id
      unless self.id
        self.id = self.class.deterministic_id(self.name)
      end
    end
  end
end
