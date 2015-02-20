module MegaBar 
  class Layout < ActiveRecord::Base
    belongs_to :page
    has_many :layouts, dependent: :destroy
    scope :by_page, ->(page_id) { where(page_id: page_id) if page_id.present? }

  end
end 
