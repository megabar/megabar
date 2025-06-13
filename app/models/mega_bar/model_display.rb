module MegaBar
  class ModelDisplay < ActiveRecord::Base
    belongs_to :block
    belongs_to :model
    has_many :field_displays, dependent: :destroy
    has_one :model_display_collection, dependent: :destroy
    validates_presence_of :block_id, :model_id, :action, :format
    attr_accessor :new_field_display, :edit_field_display, :index_field_display, :show_field_display, :authorized
    before_create :set_deterministic_id
    after_save    :make_field_displays
    after_save    :make_collection_settings

    validates :series, uniqueness: { scope: [:action, :block_id] }

    # Deterministic ID generation for ModelDisplays
    # ID range: 2000-2999
    def self.deterministic_id(block_id, model_id, action, series = nil)
      # Include series to make model displays unique per series
      identifier = series ? "#{block_id}_#{model_id}_#{action}_#{series}" : "#{block_id}_#{model_id}_#{action}"
      hash = Digest::MD5.hexdigest(identifier)
      base_id = 2000 + (hash.to_i(16) % 1000)
      
      # Check for collisions and increment if needed
      while MegaBar::ModelDisplay.exists?(id: base_id)
        base_id += 1
        break if base_id >= 3000  # Don't overflow into next range
      end
      
      base_id
    end

    scope :by_model, ->(model_id) { where(model_id: model_id) if model_id.present? }
    scope :by_action, ->(action) { where(action: action) if action.present? }
    scope :by_block, ->(block_id) { where(block_id: block_id) if block_id.present? }

    private

    def set_deterministic_id
      # Only set deterministic ID if not already set
      unless self.id
        self.id = self.class.deterministic_id(self.block_id, self.model_id, self.action, self.series)
      end
    end

    public

    def make_collection_settings
      ModelDisplayCollection.create(model_display_id: self.id) if self.collection_or_member == 'collection'
    end 

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
        else 
          actions << {format: 'textread', field_id: field.id, header: field.field.humanize}  if !FieldDisplay.by_model_display_id(self.id).by_fields(field.id).present?          
        end
      end
      actions.each do | action |
        FieldDisplay.create(model_display_id: self.id, :field_id=>action[:field_id], :format=>action[:format], :header=>action[:header])
      end
    end
  end
end
