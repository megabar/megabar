module MegaBar
  class FieldDisplay < ActiveRecord::Base
  after_save :make_data_display
  belongs_to :field
  has_many :textboxes, dependent: :destroy
  has_many :textreads, dependent: :destroy

  scope :by_fields, ->(fields) { where(field_id: fields) }
  scope :by_action, ->(action) { where(action: action) }
    def make_data_display 
      return if ENV['mega_bar_data_loading'] == 'yes'
      data_display_class = ("MegaBar::" + self.format.to_s.classify).constantize
      data_display_obj = data_display_class.new
      model_id = data_display_obj.get_model_id
      fields = Field.by_model(model_id)
      fields_defaults = {}
      fields.each do |field| 
        unless field.default_value.nil?
          fields_defaults[field.field.parameterize.underscore.to_sym] = field.default_value
        end
      end
      fields_defaults[:field_display_id] = self.id
      data_display_class.where(:field_display_id => self.id).first_or_create(fields_defaults)
      f = Field.where(id: self.field_id)
      #logger.info 'make_data_display: made a ' + data_display_class + ' for field_display ' + self.id + ' (action: ' + self.action + ', table: ' + f[0][:tablename] + ', field: ' + f[0][:field] + ') with values: ' + fields_defaults.inspect
    end
  end
end