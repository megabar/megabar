module MegaBar
  class SiteJoin < ActiveRecord::Base
    belongs_to :siteable, polymorphic: true #, optional: true
    belongs_to :site
    validates_presence_of :siteable_type, allow_blank: false
    validates_presence_of :site_id, allow_blank: false

    before_create :set_deterministic_id

    # Deterministic ID generation for SiteJoins
    # ID range: 22000-22999
    def self.deterministic_id(site_id, siteable_type, siteable_id)
      # Use site_id, siteable_type, and siteable_id to create unique identifier
      identifier = "#{site_id}_#{siteable_type}_#{siteable_id}"
      hash = Digest::MD5.hexdigest(identifier)
      base_id = 22000 + (hash.to_i(16) % 1000)
      
      # Check for collisions and increment if needed
      while MegaBar::SiteJoin.exists?(id: base_id)
        base_id += 1
        break if base_id >= 23000  # Don't overflow into next range
      end
      
      base_id
    end

    private

    def set_deterministic_id
      unless self.id
        self.id = self.class.deterministic_id(self.site_id, self.siteable_type, self.siteable_id)
      end
    end
  end
end
