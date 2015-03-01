module MegaBar 
  class Page < ActiveRecord::Base
    has_many :layouts, dependent: :destroy
    scope :by_route, ->(route) { where(path: route) if route.present? }
    attr_accessor :make_layout_and_block, :block_text, :model_id, :base_name
    after_create :create_layout_for_page
    validates_presence_of :path, :name
  

    def create_layout_for_page
      base_name = (self.base_name.nil? || self.base_name.empty?) ? self.name : self.base_name
      _layout = Layout.create(page_id: self.id, name: base_name.humanize + ' Layout', base_name: base_name, make_block: true, block_text: self.block_text, model_id: self.model_id)  if (!Layout.by_page(self.id).present? && @make_layout_and_block == 'y')
    end
    
  end
end