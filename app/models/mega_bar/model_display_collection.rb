module MegaBar 
  class ModelDisplayCollection < ActiveRecord::Base
    belongs_to :model_display
    validates_presence_of :model_display_id
    scope :by_model_display_id, ->(model_display_id) { where(model_display_id: model_display_id) }
   
  end
end 
