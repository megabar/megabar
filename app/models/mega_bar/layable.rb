module MegaBar 
  class Layable < ActiveRecord::Base
    belongs_to :layout
    belongs_to :layout_section
    belongs_to :template_section

    before_create :set_deterministic_id
    after_destroy :delete_dependents

    # Deterministic ID generation for Layables
    # ID range: 20000-20999
    def self.deterministic_id(layout_id, layout_section_id)
      # Use layout_id and layout_section_id to create unique identifier
      identifier = "#{layout_id}_#{layout_section_id}"
      hash = Digest::MD5.hexdigest(identifier)
      base_id = 20000 + (hash.to_i(16) % 1000)
      
      # Check for collisions and increment if needed
      while MegaBar::Layable.exists?(id: base_id)
        base_id += 1
        break if base_id >= 21000  # Don't overflow into next range
      end
      
      base_id
    end

    def delete_dependents
     #only destroy layoutsections if no other layables use it.
     LayoutSection.destroy(self.layout_section_id) if Layable.where(layout_section_id: self.layout_section_id).blank?
    end

    private

    def set_deterministic_id
      unless self.id
        self.id = self.class.deterministic_id(self.layout_id, self.layout_section_id)
      end
    end
  end
end 
