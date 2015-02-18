module MegaBar 
  class Block < ActiveRecord::Base
     belongs_to :layout
     scope :by_model, ->(model_id) { where(id: model_id) if model_id.present? }
  end
end 
