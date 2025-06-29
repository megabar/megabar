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
      
      # Generate the field migration using direct Rails generator invocation (more reliable)
      begin
        logger.info("Invoking MegaBar field generator for #{self.field} on #{self.tablename}...")
        generator_args = [self.tablename, self.field, self.data_type + boolean]
        
        # Use Rails::Generators.invoke to call the generator directly
        Rails::Generators.invoke('mega_bar:mega_bar_fields', generator_args, {
          behavior: :invoke,
          destination_root: Rails.root
        })
        
        logger.info("✅ Field generator completed successfully for #{self.field}")
        
      rescue => e
        logger.warn("Direct field generator invocation failed: #{e.message}, falling back to system call")
        
        # Fallback to system call if direct invocation fails
        generator_result = system 'bundle exec rails g mega_bar:mega_bar_fields ' + self.tablename + ' ' + self.field + ' ' + self.data_type + boolean
        logger.info("Fallback field generator result: #{generator_result}")
      end
      
      # Run migrations using Rails internal methods (more reliable than system calls)
      logger.info("Running field migrations for #{self.field} on #{self.tablename}...")
      
      begin
        # Method 1: Use ActiveRecord::MigrationContext (most reliable)
        migration_context = ActiveRecord::MigrationContext.new(Rails.root.join('db/migrate'))
        migration_context.migrate
        logger.info("Field migrations completed successfully using MigrationContext")
      rescue => e
        logger.warn("MigrationContext failed: #{e.message}, trying Rails::Command::DbCommand")
        
        begin
          # Method 2: Use Rails command system
          Rails::Command::DbCommand.new.migrate
          logger.info("Field migrations completed successfully using Rails::Command")
        rescue => e2
          logger.warn("Rails::Command failed: #{e2.message}, falling back to system call")
          
          # Method 3: Fallback to system call with better error handling
          migration_result = system 'bundle exec rails db:migrate'
          if migration_result
            logger.info("Field migrations completed successfully using system call")
          else
            logger.error("All migration methods failed for field #{self.field}")
          end
        end
      end
      
      if self.data_type == 'references' 
        self.field = self.field + "_id"
        self.save
      end
      
      # ✅ CRITICAL FIX: Reload the target model class to recognize new column
      begin
        target_model_name = self.tablename.classify
        target_model_class = target_model_name.constantize
        target_model_class.reset_column_information
        logger.info("✅ Model #{target_model_name} column information reloaded - new field '#{self.field}' should now be available")
      rescue => e
        logger.warn("Failed to reload model class #{target_model_name}: #{e.message}")
      end
    end
    def delete_field_displays
      FieldDisplay.by_fields(self.id).destroy_all
    end
  end
end
