module MegaBar
  class Player < ActiveRecord::Base
    acts_as_list
    validates_presence_of :field_display_id
    validates_uniqueness_of :field_display_id
    scope :by_field_display_id, ->(field_display_id) { where(field_display_id: field_display_id)}
    
    # 🚀 REVOLUTIONARY DETERMINISTIC ID SYSTEM
    # This model uses deterministic IDs for conflict-free seed loading
    before_create :set_deterministic_id
    
    # Deterministic ID generation for Player UI Components
    # ID range: 29000-29999
    def self.deterministic_id(field_display_id)
      identifier = "player_#{field_display_id}"
      hash = Digest::MD5.hexdigest(identifier)
      base_id = 29000 + (hash.to_i(16) % 1000)
      
      while self.exists?(id: base_id)
        base_id += 1
        break if base_id >= 30000
      end
      
      base_id
    end

    def get_model_id
      # TODO: Set the correct model ID for Player
      9778  # This should be the Player model's deterministic ID
    end
    
    def controller_name
      'mega_bar/players'
    end

    private

    def set_deterministic_id
      unless self.id
        # Use field_display_id as the unique identifier for Player components
        self.id = self.class.deterministic_id(self.field_display_id)
      end
    end
  end
end 