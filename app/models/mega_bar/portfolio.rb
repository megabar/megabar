module MegaBar
  class Portfolio < ActiveRecord::Base
    has_many :sites
    belongs_to :theme
    validates_uniqueness_of :code_name
    validates_presence_of :code_name, allow_blank: false
    validates_presence_of :name, allow_blank: false
    validates_presence_of :theme_id, allow_blank: false

    before_create :set_deterministic_id

    # Deterministic ID generation for Portfolios
    # ID range: 14000-14999
    def self.deterministic_id(code_name)
      # Use code_name to create unique identifier
      identifier = code_name.to_s
      hash = Digest::MD5.hexdigest(identifier)
      base_id = 14000 + (hash.to_i(16) % 1000)
      
      # Check for collisions and increment if needed
      while MegaBar::Portfolio.exists?(id: base_id)
        base_id += 1
        break if base_id >= 15000  # Don't overflow into next range
      end
      
      base_id
    end

    private

    def set_deterministic_id
      unless self.id
        self.id = self.class.deterministic_id(self.code_name)
      end
    end
  end
end
