module MegaBar
  class LayoutSection < ActiveRecord::Base
    attr_accessor :template_section_id, :model_id, :block_text, :base_name, :make_block, :new_model_display, :edit_model_display, :index_model_display, :show_model_display

    has_many :layables, dependent: :destroy
    has_many :layouts, through: :layables
    has_many :blocks, -> { order(position: :asc)}, dependent: :destroy

    validates_presence_of :code_name
    validates_uniqueness_of :code_name

    before_create :set_deterministic_id
    after_create :create_block_for_section

    # Deterministic ID generation for LayoutSections
    # ID range: 6000-6999
    def self.deterministic_id(code_name)
      # Use code_name to create unique identifier
      identifier = code_name.to_s
      hash = Digest::MD5.hexdigest(identifier)
      base_id = 6000 + (hash.to_i(16) % 1000)
      
      # Check for collisions and increment if needed
      while MegaBar::LayoutSection.exists?(id: base_id)
        base_id += 1
        break if base_id >= 7000  # Don't overflow into next range
      end
      
      base_id
    end

    def create_block_for_section
      # Only create blocks if make_block is explicitly true (from the page form checkbox)
      return unless self.make_block
      
      # path_base:  MegaBar::Page.find(self.page_id).path, # could be added in below. but doesnt look necessary.
      
      # Separate database attributes from attr_accessors
      db_attributes = {
        layout_section_id: self.id, 
        name: self.code_name.humanize + ' Block', 
        actions: 'current'
      }
      db_attributes[:html] = self.block_text if self.block_text

      # Create the block with database attributes only
      block = Block.new(db_attributes)
      
      # Set the attr_accessor attributes if we have a model
      if self.model_id
        block.model_id = self.model_id
        # For model-based pages, create all CRUD displays
        block.new_model_display = true
        block.edit_model_display = true
        block.index_model_display = true
        block.show_model_display = true
      end
      
      # Save the block (this will trigger callbacks that use the attr_accessors)
      block.save!
      block
    end

    private

    def set_deterministic_id
      unless self.id
        self.id = self.class.deterministic_id(self.code_name)
      end
    end
  end
end
