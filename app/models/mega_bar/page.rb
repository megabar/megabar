module MegaBar 
  class Page < ActiveRecord::Base
    has_many :layouts, dependent: :destroy
  end
end 
