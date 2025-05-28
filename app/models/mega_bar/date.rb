module MegaBar
  class Date < ActiveRecord::Base
    validates_presence_of :field_display_id
    scope :by_field_display_id, ->(field_display_id) { where(field_display_id: field_display_id)}
    validates_uniqueness_of :field_display_id
    
    before_create :set_deterministic_id

    def controller_name
      'mega_bar/dates'
    end

    def get_model_id
      29
    end

    # Deterministic ID generation for Date (range: 28000-28999)
    def self.deterministic_id(field_display_id)
      identifier = "date_#{field_display_id}"
      hash = Digest::MD5.hexdigest(identifier)
      base_id = 28000 + (hash.to_i(16) % 1000)
      
      while MegaBar::Date.exists?(id: base_id)
        base_id += 1
        break if base_id >= 29000
      end
      
      base_id
    end

    private

    def set_deterministic_id
      unless self.id
        self.id = self.class.deterministic_id(self.field_display_id)
      end
    end
  end
end 
