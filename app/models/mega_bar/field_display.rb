module MegaBar
  require 'acts_as_list'
  class FieldDisplay < ActiveRecord::Base
    after_save :make_data_display
    belongs_to :model_display
    validates_presence_of :model_display_id, :field_id
    before_create :set_deterministic_id
    has_many :textboxes, dependent: :destroy
    has_many :textreads, dependent: :destroy
    has_many :selects, dependent: :destroy
    has_many :textareas, dependent: :destroy
    has_many :checkboxes, dependent: :destroy

    # Deterministic ID generation for FieldDisplays
    # ID range: 3000-3999
    def self.deterministic_id(model_display_id, field_id, position = nil)
      # Include position to make field displays unique per position
      identifier = position ? "#{model_display_id}_#{field_id}_#{position}" : "#{model_display_id}_#{field_id}"
      hash = Digest::MD5.hexdigest(identifier)
      base_id = 3000 + (hash.to_i(16) % 1000)
      
      # Check for collisions and increment if needed
      while MegaBar::FieldDisplay.exists?(id: base_id)
        base_id += 1
        break if base_id >= 4000  # Don't overflow into next range
      end
      
      base_id
    end

    scope :by_fields, ->(fields) { where(field_id: fields) }
    scope :by_action, ->(action) { where(action: action) }
    scope :by_model_display_id, ->(model_display_id) { where(model_display_id: model_display_id) }
    validates_uniqueness_of :field_id, scope: :model_display_id
    acts_as_list scope: :model_display unless Rails.env.test?

    private

    def set_deterministic_id
      # Only set deterministic ID if not already set
      unless self.id
        self.id = self.class.deterministic_id(self.model_display_id, self.field_id, self.position)
      end
    end

    public

    def make_data_display
      return if self.format.to_s == 'off'
      Textbox.by_field_display_id(self.id).delete_all unless self.format == 'textbox'
      Textread.by_field_display_id(self.id).delete_all unless self.format == 'textread'
      Select.by_field_display_id(self.id).delete_all unless self.format == 'select'
      Textarea.by_field_display_id(self.id).delete_all unless self.format == 'textarea'
      Checkbox.by_field_display_id(self.id).delete_all unless self.format == 'checkbox'
      Date.by_field_display_id(self.id).delete_all unless self.format == 'date'
      obj = ("MegaBar::" + self.format.to_s.classify).constantize.where(:field_display_id => self.id).first_or_initialize()
      unless obj.id.present?
        fields = Field.by_model(get_model_id)
        fields_defaults = {}
        fields.each do |field|
          unless (field.default_value.nil? || field.default_value == 'off')
            # Only set attributes that exist in the model's schema
            if obj.respond_to?("#{field.field.parameterize.underscore}=")
              fields_defaults[field.field.parameterize.underscore.to_sym] = field.default_value
            end
          end
        end
        fields_defaults[:field_display_id] = self.id
        fields_defaults[:checked] = 'false' if self.format == 'checkbox'
        
        # Auto-configure Date records to use datepicker format
        if self.format == 'date'
          fields_defaults[:format] = 'datepicker'
          # Set other sensible defaults for date pickers
          fields_defaults[:transformation] = 'fuzzy' unless fields_defaults[:transformation].present?
        end
        
        data_display = obj.update(fields_defaults)
      end
      f = Field.where(id: self.field_id)
    end

    def get_model_id
      data_display_obj = ("MegaBar::" + self.format.to_s.classify).constantize.new
      model_id = data_display_obj.get_model_id
    end

  end
end
