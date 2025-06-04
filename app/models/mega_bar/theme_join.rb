module MegaBar
  class ThemeJoin < ActiveRecord::Base
    belongs_to :themeable, polymorphic: true #, optional: true
    belongs_to :theme
    validates_presence_of :themeable_type, allow_blank: false
    validates_presence_of :theme_id, allow_blank: false

    before_create :set_deterministic_id

    # Deterministic ID generation for ThemeJoins
    # ID range: 21000-21999
    def self.deterministic_id(theme_id, themeable_type, themeable_id)
      # Use theme_id, themeable_type, and themeable_id to create unique identifier
      identifier = "#{theme_id}_#{themeable_type}_#{themeable_id}"
      hash = Digest::MD5.hexdigest(identifier)
      base_id = 21000 + (hash.to_i(16) % 1000)
      
      # Check for collisions and increment if needed
      while MegaBar::ThemeJoin.exists?(id: base_id)
        base_id += 1
        break if base_id >= 22000  # Don't overflow into next range
      end
      
      base_id
    end

    private

    def set_deterministic_id
      unless self.id
        self.id = self.class.deterministic_id(self.theme_id, self.themeable_type, self.themeable_id)
      end
    end
  end
end
