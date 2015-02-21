module MegaBar 
  class Page < ActiveRecord::Base
    has_many :layouts, dependent: :destroy
    scope :by_route, ->(route) { where(path: route) if route.present? }

  end
end 
