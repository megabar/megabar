module MegaBar
  require 'acts_as_list'
  class FieldDisplay < ActiveRecord::Base
    after_save :make_data_display
    belongs_to :model_display
    validates_presence_of :model_display_id, :field_id
    has_many :textboxes, dependent: :destroy
    has_many :textreads, dependent: :destroy
    has_many :selects, dependent: :destroy
    has_many :textareas, dependent: :destroy
    has_many :checkboxes, dependent: :destroy

    scope :by_fields, ->(fields) { where(field_id: fields) }
    scope :by_action, ->(action) { where(action: action) }
    scope :by_model_display_id, ->(model_display_id) { where(model_display_id: model_display_id) }
    validates_uniqueness_of :field_id, scope: :model_display_id
    acts_as_list scope: :model_display unless Rails.env.test?

    def make_data_display
      return if self.format.to_s == 'off'
      Textbox.by_field_display_id(self.id).delete_all unless self.format == 'textbox'
      Textread.by_field_display_id(self.id).delete_all unless self.format == 'textread'
      Select.by_field_display_id(self.id).delete_all unless self.format == 'select'
      Textarea.by_field_display_id(self.id).delete_all unless self.format == 'textarea'
      Checkbox.by_field_display_id(self.id).delete_all unless self.format == 'checkbox'
      obj = ("MegaBar::" + self.format.to_s.classify).constantize.where(:field_display_id => self.id).first_or_initialize()
      unless obj.id.present?
        fields = Field.by_model(get_model_id)
        fields_defaults = {}
        fields.each do |field|
          unless (field.default_value.nil? || field.default_value == 'off')
            fields_defaults[field.field.parameterize.underscore.to_sym] = field.default_value
          end
        end
        fields_defaults[:field_display_id] = self.id
        fields_defaults[:checked] = 'false' if self.format == 'checkbox'
        data_display = obj.save(fields_defaults)
      end
      f = Field.where(id: self.field_id)
    end

    def get_model_id
      data_display_obj = ("MegaBar::" + self.format.to_s.classify).constantize.new
      model_id = data_display_obj.get_model_id
    end

  end
end
