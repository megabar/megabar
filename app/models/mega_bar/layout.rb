module MegaBar
  class Layout < ActiveRecord::Base
    belongs_to :page
    belongs_to :template
    has_many :theme_joins, as: :themeable
    has_many :themes, through: :theme_joins, dependent: :destroy
    has_many :site_joins, as: :siteable
    has_many :sites, through: :site_joins, dependent: :destroy
    after_create :create_layable_sections


    has_many :layables
    has_many :layout_sections, through: :layables, dependent: :destroy


    attr_accessor :make_block, :block_text, :model_id, :base_name
    # has_many :blocks, dependent: :destroy
    scope :by_page, ->(page_id) { where(page_id: page_id) if page_id.present? }
    validates_uniqueness_of :name, scope: :page_id,  message: "dupe layout name for this page"
    validates_presence_of :page_id

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
