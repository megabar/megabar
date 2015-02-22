module MegaBar 
  class Layout < ActiveRecord::Base
    belongs_to :page
    has_many :blocks, dependent: :destroy
    attr_accessor :make_block, :block_text, :new_model_id, :base_name
    after_create :create_block_for_layout

    scope :by_page, ->(page_id) { where(page_id: page_id) if page_id.present? }

    def create_block_for_layout
      byebug
      Block.create(layout_id: self.id, name: self.base_name + ' on ' + self.base_name + ' Block', actions: 'sine', html: self.block_text, new_model_id: self.new_model_id)
      byebug
    end

  end
end 