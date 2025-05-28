module MegaBar
  class Field < ActiveRecord::Base
    after_create  :make_migration #, :only => [:create] #add update.
    after_destroy :delete_field_displays
    after_save    :make_field_displays
    attr_accessor :model_display_ids, :new_field_display, :edit_field_display, :index_field_display, :show_field_display, :block_id
    before_create :handle_simple_relation
    before_create :set_deterministic_id
    belongs_to    :model
    has_many      :options, dependent: :destroy
    scope         :by_model, ->(model_id) { where(model_id: model_id) if model_id.present? }
    validate      :table_exists, on: :create unless Rails.env.test?
    validates_format_of :tablename, on: [:create, :update], :multiline => true, allow_nil: false, with: /[a-z]+/, message: 'no caps'
    validates_presence_of :model_id, :tablename, :field, :default_data_format, :default_data_format_edit
    validates_uniqueness_of :field, scope: :model_id,  message: "dupe field for this model"

    # Deterministic ID generation for Fields
    # ID range: 1000-1999
    def self.deterministic_id(name, field_type, model_id = nil)
      # Include model_id to make fields unique per model
      identifier = model_id ? "#{name}_#{field_type}_#{model_id}" : "#{name}_#{field_type}"
      hash = Digest::MD5.hexdigest(identifier)
      base_id = 1000 + (hash.to_i(16) % 1000)
      
      # Check for collisions and increment if needed
      while MegaBar::Field.exists?(id: base_id)
        base_id += 1
        break if base_id >= 2000  # Don't overflow into next range
      end
      
      base_id
    end

    private

    def set_deterministic_id
      # Only set deterministic ID if not already set
      unless self.id
        self.id = self.class.deterministic_id(self.field, self.data_type, self.model_id)
      end
    end

    def table_exists
      return true if self.tablename == 'accessor'
      modle = Model.find(self.model_id) #this is a ugly dependency so this doesn't run in test environment.
      prefix = modle.modyule.nil? || modle.modyule.empty? ? '' : modle.modyule.split('::').map { | m | m.underscore }.join('_') + '_'
      self.tablename =  prefix + self.tablename if prefix + self.tablename == modle.tablename
      return true if ActiveRecord::Base.connection.table_exists? self.tablename
      errors.add(:base, 'That table does not exist')
      return false
    end

    def make_field_displays
      return unless self.model_display_ids.present?
      self.model_display_ids = self.model_display_ids.reject(&:blank?)
      mds = ModelDisplay.find(self.model_display_ids) if self.model_display_ids.present?
      return unless mds
      mds.each do | md |
        data_display = ['new', 'edit'].include?(md.action) ? self.default_data_format_edit :  self.default_data_format

        if md.action == 'index'
          wrapper = self.default_index_wrapper.present? ? self.default_index_wrapper : 'div'
        elsif md.action == 'show'
          wrapper = self.default_show_wrapper.present? ? self.default_show_wrapper : 'div'
        end
        FieldDisplay.create(model_display_id: md.id, field_id: self.id, format:data_display, header: self.field.humanize, wrapper: wrapper) #note that index_wrapper should be refactored to just be wrapper.
      end
    end

    def handle_simple_relation

    end

    def make_migration
      return true if ActiveModel::Type::Boolean.new.cast(self.accessor)
      return if Model.connection.column_exists?(self.tablename,  self.field)
      # if self.field.ends_with('_id') byebug
      byebug if self.data_type == 'datetime' or self.data_type == 'boolean'
      boolean =   self.data_type == 'boolean' ? ' null: false, default: false' : '' #todo allow default true.
      system 'bundle exec rails g mega_bar:mega_bar_fields ' + self.tablename + ' ' + self.field + ' ' + self.data_type + boolean
      system 'bundle exec rails db:migrate'
      if self.data_type == 'references' 
        self.field = self.field + "_id"
        self.save
      end
        
    end
    def delete_field_displays
      FieldDisplay.by_fields(self.id).destroy_all
    end
  end
end
