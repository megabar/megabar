module MegaBar 
  class Layout < ActiveRecord::Base
    belongs_to :page
    has_many :layouts, dependent: :destroy
    
  end
end 
