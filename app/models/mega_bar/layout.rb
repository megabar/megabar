module MegaBar
  class Layout < ActiveRecord::Base
    has_many :theme_joins, as: :themeable
    has_many :themes, through: :theme_joins, dependent: :destroy
    has_many :site_joins, as: :siteable
    has_many :sites, through: :site_joins, dependent: :destroy
    after_create    :create_block_for_layout

    attr_accessor :make_block, :block_text, :model_id, :base_name
    belongs_to :page
    has_many :blocks, dependent: :destroy
    scope :by_page, ->(page_id) { where(page_id: page_id) if page_id.present? }
    validates_uniqueness_of :name, scope: :page_id,  message: "dupe layout name for this page"
    validates_presence_of :page_id

    def create_block_for_layout
      # path_base:  MegaBar::Page.find(self.page_id).path, # could be added in below. but doesnt look necessary.
      block_hash = {layout_id: self.id, name: self.base_name.humanize + ' on ' + self.name + ' Block', actions: 'current', model_id: self.model_id, new_model_display: 'y', edit_model_display: 'y', index_model_display: 'y', show_model_display: 'y'}
      block_hash = block_hash.merge(html: self.block_text) if self.block_text
      Block.create(block_hash)
    end

  end
end
