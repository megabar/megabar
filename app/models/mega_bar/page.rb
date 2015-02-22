module MegaBar 
  class Page < ActiveRecord::Base
    has_many :layouts, dependent: :destroy
    attr_accessor :make_layout_and_block, :block_text
    after_save :create_layout_and_block



    def create_layout_and_block
      byebug
      _layout = Layout.create(page_id: self.id, name: self.name + ' Layout', make_block: true)  if (!Layout.by_page(self.id).present? && @new_layout_display == 'y')
      Block.create(layout_id: _layout.id, name: self.name + ' on ' + self.name + ' Block', actions: 'sine', text: self.block_text )
    end
    
  end
end 