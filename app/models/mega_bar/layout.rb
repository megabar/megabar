module MegaBar 
  class Layout < ActiveRecord::Base
    belongs_to :page
    has_many :layouts, dependent: :destroy
    scope :by_page, ->(page_id) { where(page_id: page_id) if page_id.present? }
    has_many :blocks, dependent: :destroy
    attr_accessor :make_block, :block_text, :model_id, :base_name

    after_create    :create_block_for_layout
    validates_uniqueness_of :name


    def create_block_for_layout
      Block.create(layout_id: self.id, name: self.base_name.humanize + ' on ' + self.name + ' Block', actions: 'sine', html: self.block_text, model_id: self.model_id)
    end

  end
end 
