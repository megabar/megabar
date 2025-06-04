module MegaBar
  class Layout < ActiveRecord::Base
    belongs_to :page
    belongs_to :template
    has_many :theme_joins, as: :themeable
    has_many :themes, through: :theme_joins, dependent: :destroy
    has_many :site_joins, as: :siteable
    has_many :sites, through: :site_joins, dependent: :destroy
    before_create :set_deterministic_id
    after_create :create_layable_sections

    has_many :layables
    has_many :layout_sections, through: :layables, dependent: :destroy

    # Deterministic ID generation for Layouts
    # ID range: 5000-5999
    def self.deterministic_id(page_id, name, base_name = nil)
      # Use page_id, name, and base_name to create unique identifier
      identifier = base_name ? "#{page_id}_#{name}_#{base_name}" : "#{page_id}_#{name}"
      hash = Digest::MD5.hexdigest(identifier)
      base_id = 5000 + (hash.to_i(16) % 1000)
      
      # Check for collisions and increment if needed
      while MegaBar::Layout.exists?(id: base_id)
        base_id += 1
        break if base_id >= 6000  # Don't overflow into next range
      end
      
      base_id
    end

    attr_accessor :make_block, :block_text, :model_id, :base_name
    # has_many :blocks, dependent: :destroy
    scope :by_page, ->(page_id) { where(page_id: page_id) if page_id.present? }
    validates_uniqueness_of :name, scope: :page_id,  message: "dupe layout name for this page"
    validates_presence_of :page_id

    private

    def set_deterministic_id
      # Only set deterministic ID if not already set
      unless self.id
        self.id = self.class.deterministic_id(self.page_id, self.name, self.base_name)
      end
    end

    public

    def create_layable_sections
      template = Template.find(self.template_id)
      template.template_sections.each do |section|
        if section.code_name == 'main'
          layout_section_hash = { code_name: self.base_name + '_' + section.code_name, block_text: self.block_text, model_id: self.model_id, base_name: self.base_name}
        else
          layout_section_hash = { code_name: self.base_name + '_' + section.code_name, block_text: self.block_text, base_name: self.base_name}
        end
        ls = LayoutSection.create(layout_section_hash)
        layable = Layable.create(layout_section_id: ls.id, template_section_id: section.id, layout_id: self.id)
      end
    end

  end
end
