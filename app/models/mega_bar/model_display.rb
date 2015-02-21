module MegaBar
  class ModelDisplay < ActiveRecord::Base
    belongs_to :blocks
    has_many :field_displays, dependent: :destroy
    validates_presence_of :block_id, :action, :format

    # TODO : gotta enforce that only model_displays with the same model and action can go into any one block.

    scope :by_action, ->(action) { where(action: action) if action.present? }
    scope :by_block, ->(block_id) { where(block_id: block_id) if block_id.present? }

  end
end