module MegaBar
  class Date < ActiveRecord::Base
    acts_as_list
    
    # 🚀 REVOLUTIONARY DETERMINISTIC ID SYSTEM
    # This model uses deterministic IDs for conflict-free seed loading
    before_create :set_deterministic_id
    
    # Deterministic ID generation for Date UI Components
    # ID range: 28000-28999
    def self.deterministic_id(field_display_id)
      identifier = "date_#{field_display_id}"
      hash = Digest::MD5.hexdigest(identifier)
      base_id = 28000 + (hash.to_i(16) % 1000)
      
      while self.exists?(id: base_id)
        base_id += 1
        break if base_id >= 29000
      end
      
      base_id
    end

    private

    def set_deterministic_id
      unless self.id
        # Use field_display_id as the unique identifier for Date components
        self.id = self.class.deterministic_id(self.field_display_id)
      end
    end
  end
end 
