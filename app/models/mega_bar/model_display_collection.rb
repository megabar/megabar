module MegaBar 
  class ModelDisplayCollection < ActiveRecord::Base
    belongs_to :model_display
    validates_presence_of :model_display_id
    scope :by_model_display_id, ->(model_display_id) { where(model_display_id: model_display_id) }

    before_create :set_deterministic_id

    # Deterministic ID generation for ModelDisplayCollections
    # ID range: 25000-25999
    def self.deterministic_id(model_display_id)
      # Use model_display_id to create unique identifier
      identifier = "model_display_collection_#{model_display_id}"
      hash = Digest::MD5.hexdigest(identifier)
      base_id = 25000 + (hash.to_i(16) % 1000)
      
      # Check for collisions and increment if needed
      while MegaBar::ModelDisplayCollection.exists?(id: base_id)
        base_id += 1
        break if base_id >= 26000  # Don't overflow into next range
      end
      
      base_id
    end

    private

    def set_deterministic_id
      unless self.id
        self.id = self.class.deterministic_id(self.model_display_id)
      end
    end
  end
end 
