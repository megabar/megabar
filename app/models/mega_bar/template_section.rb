module MegaBar
  class TemplateSection < ActiveRecord::Base
    belongs_to :template
    validates_presence_of :name, allow_blank: false
    validates_presence_of :code_name, allow_blank: false
    validates_presence_of :template_id, allow_blank: false
    validates_uniqueness_of :code_name,  scope: [:template_id]

    before_create :set_deterministic_id

    # Deterministic ID generation for TemplateSections
    # ID range: 13000-13999
    def self.deterministic_id(code_name, template_id)
      # Use code_name and template_id to create unique identifier
      identifier = "#{code_name}_#{template_id}"
      hash = Digest::MD5.hexdigest(identifier)
      base_id = 13000 + (hash.to_i(16) % 1000)
      
      # Check for collisions and increment if needed
      while MegaBar::TemplateSection.exists?(id: base_id)
        base_id += 1
        break if base_id >= 14000  # Don't overflow into next range
      end
      
      base_id
    end

    private

    def set_deterministic_id
      unless self.id
        self.id = self.class.deterministic_id(self.code_name, self.template_id)
      end
    end
  end
end
