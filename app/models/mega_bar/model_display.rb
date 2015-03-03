module MegaBar
  class ModelDisplay < ActiveRecord::Base
    belongs_to :blocks
    has_many :field_displays, dependent: :destroy
    validates_presence_of :block_id, :model_id, :action, :format
    attr_accessor :new_field_display, :edit_field_display, :index_field_display, :show_field_display
    after_save    :make_field_displays
    
    scope :by_model, ->(model_id) { where(model_id: model_id) if model_id.present? }
    scope :by_action, ->(action) { where(action: action) if action.present? }
    scope :by_block, ->(block_id) { where(block_id: block_id) if block_id.present? }

    def make_field_displays 
      actions = []
      fields = Field.by_model(self.model_id)
      fields.each do | field | 
        case self.action
        when 'new'
          actions << {format: field.default_data_format, field_id: field.id, header: field.field.humanize}  if !FieldDisplay.by_model_display_id(self.id).by_fields(field.id).present?
        when 'index'
          actions << {format: 'textread', field_id: field.id, header: field.field.humanize}  if !FieldDisplay.by_model_display_id(self.id).by_fields(field.id).present? 
        when 'show'
          actions << {format: 'textread', field_id: field.id, header: field.field.humanize}  if !FieldDisplay.by_model_display_id(self.id).by_fields(field.id).present?
        when 'edit'
          actions << {format: field.default_data_format_edit, field_id: field.id, header: field.field.humanize}  if !FieldDisplay.by_model_display_id(self.id).by_fields(field.id).present?
        end
      end
      actions.each do | action |
        FieldDisplay.create(model_display_id: self.id,:field_id=>action[:field_id], :format=>action[:format], :header=>action[:header])
      end
    end
  end
end