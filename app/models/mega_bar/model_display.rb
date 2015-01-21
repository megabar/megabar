module MegaBar
  class ModelDisplay < ActiveRecord::Base
    self.table_name = "mega_bar_model_displays"
    belongs_to :models
    validates_presence_of :model_id

    scope :by_model, ->(model_id) { where(model_id: model_id) if model_id.present? }
    scope :by_action, ->(action) { where(action: action) if action.present? }

  end
end