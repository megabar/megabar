module MegaBar
  class RecordsFormat < ActiveRecord::Base
    self.table_name = 'mega_bar_records_formats'

    before_create :set_deterministic_id

    # Deterministic ID generation for RecordsFormats
    # ID range: 27000-27999
    def self.deterministic_id(name)
      # Use name to create unique identifier
      identifier = "records_format_#{name}"
      hash = Digest::MD5.hexdigest(identifier)
      base_id = 27000 + (hash.to_i(16) % 1000)
      
      # Check for collisions and increment if needed
      while MegaBar::RecordsFormat.exists?(id: base_id)
        base_id += 1
        break if base_id >= 28000  # Don't overflow into next range
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
