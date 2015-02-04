module MegaBar
  class ModelDisplay < ActiveRecord::Base
    self.table_name = "mega_bar_model_displays"
    belongs_to :models
    has_many :field_displays, dependent: :destroy
    validates_presence_of :model_id, :action, :format

    scope :by_model, ->(model_id) { where(model_id: model_id) if model_id.present? }
    scope :by_action, ->(action) { where(action: action) if action.present? }

  end
end