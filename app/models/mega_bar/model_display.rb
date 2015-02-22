module MegaBar
  class ModelDisplay < ActiveRecord::Base
    self.table_name = "mega_bar_model_displays"
    belongs_to :blocks
    has_many :field_displays, dependent: :destroy
    validates_presence_of :block_id, :model_id, :action, :format
    attr_accessor :new_field_display, :edit_field_display, :index_field_display, :show_field_display
    after_save    :make_field_displays
    
    scope :by_model, ->(model_id) { where(model_id: model_id) if model_id.present? }
    scope :by_action, ->(action) { where(action: action) if action.present? }
    scope :by_block, ->(block_id) { where(block_id: block_id) if block_id.present? }

    def make_field_displays 
      byebug
      actions = []
      index_model_display_id = ModelDisplay.by_model(self.model_id).by_action('index').pluck(:id).last
      show_model_display_id = ModelDisplay.by_model(self.model_id).by_action('show').pluck(:id).last
      new_model_display_id = ModelDisplay.by_model(self.model_id).by_action('new').pluck(:id).last
      edit_model_display_id = ModelDisplay.by_model(self.model_id).by_action('edit').pluck(:id).last

      fields = Fields.by_model(self.model_id)
      byebug
      fields.each do | field | 
        actions << {:format=>'textread', model_display_id: index_model_display_id, :field_id=>field.id, :header=>self.field.pluralize}  if (!FieldDisplay.by_model_display_id(index_model_display_id).by_fields(field.id).present? && @index_field_display == 'y')
        actions << {:format=>'textread', model_display_id: show_model_display_id, :field_id=>field.id, :header=>self.field}  if (!FieldDisplay.by_model_display_id(show_model_display_id).by_fields(field.id).present? && @show_field_display == 'y')
        actions << {:format=>field.default_data_format, model_display_id: new_model_display_id, :field_id=>field.id, :header=>self.field}  if (!FieldDisplay.by_model_display_id(new_model_display_id).by_fields(field.id).present? && @new_field_display == 'y')
        actions << {:format=>field.default_data_format_edit, model_display_id: edit_model_display_id, :field_id=>field.id, :header=>self.field}  if (!FieldDisplay.by_model_display_id(edit_model_display_id).by_fields(field.id).present? && @edit_field_display == 'y')
        actions.each do | action |
          FieldDisplay.create(model_display_id: action[:model_display_id],:field_id=>self.id, :format=>action[:format], :header=>action[:header])
        end
      end
    end
  end
end