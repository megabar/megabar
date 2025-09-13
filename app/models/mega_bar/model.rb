module MegaBar
  class Model < ActiveRecord::Base

    include MegaBar::MegaBarModelConcern

    before_create :set_deterministic_id
    before_create :standardize_modyule
    before_create :standardize_classname
    before_create :standardize_tablename
    after_create  :make_all_files
    after_save  :make_page_for_model

    after_create :make_page_for_model


    after_save    :make_position_field
    attr_accessor :make_page
    attr_writer   :model_id
    has_many      :fields, dependent: :destroy
    has_many      :model_displays, dependent: :destroy # or after_destroy delete_model_displays. see field model example
    scope         :by_model, ->(model_id) { where(id: model_id) if model_id.present? }
    validates     :classname, format: { with: /\A[A-Za-z][A-Za-z0-9\-\_]*\z/, message: "Must start with a letter and have only letters, numbers, dashes or underscores" }
    validates_presence_of :default_sort_field, :name
    validates_uniqueness_of :classname

    # Deterministic ID generation for Models
    # ID range: 9000-9999
    def self.deterministic_id(classname)
      # Use classname to create unique identifier
      identifier = classname.to_s
      hash = Digest::MD5.hexdigest(identifier)
      base_id = 9000 + (hash.to_i(16) % 1000)
      
      # Check for collisions and increment if needed
      while MegaBar::Model.exists?(id: base_id)
        base_id += 1
        break if base_id >= 10000  # Don't overflow into next range
      end
      
      base_id
    end

    def make_all_files
      logger.info("🚀 STARTING make_all_files for #{self.classname} (ID: #{self.id})")
      logger.info("📋 Model details: name=#{self.name}, tablename=#{self.tablename}, position_parent=#{self.position_parent}")
      
      # Step 1: Generate all files first (model, controller, migration)
      logger.info("📁 STEP 1: Generating files for #{self.classname}")
      logger.info("creating scaffold for " + self.classname + 'via: ' + 'rails g mega_bar:mega_bar ' + self.classname + ' ' + self.id.to_s)
      mod = self.modyule.nil? || self.modyule.empty?  ? 'no_mod' : self.modyule
      logger.info("🔧 Module: #{mod}")

      # Generate model files and migrations using system call (most reliable for production)
      logger.info("🔨 Invoking MegaBar generator for #{self.classname}...")
      generator_command = "rails g mega_bar:mega_bar_models #{mod} #{self.classname} #{self.id.to_s} #{pos}"
      logger.info("📝 Generator command: #{generator_command}")
      logger.info("📍 Position parameter: #{pos}")
      
      generator_result = system(generator_command)
      logger.info("🔄 Generator system call result: #{generator_result}")
      
      if generator_result
        logger.info("✅ Generator completed successfully for #{self.classname}")
      else
        logger.error("❌ Generator failed for #{self.classname}")
        # Try with bundle exec as fallback
        bundle_command = "bundle exec #{generator_command}"
        logger.info("🔄 Trying with bundle exec: #{bundle_command}")
        bundle_result = system(bundle_command)
        logger.info("🔄 Bundle exec result: #{bundle_result}")
        if bundle_result
          logger.info("✅ Generator completed successfully with bundle exec for #{self.classname}")
        else
          logger.error("❌ Generator failed even with bundle exec for #{self.classname}")
          logger.info("⚠️  Continuing anyway - we'll create essential fields and try migrations later")
        end
      end
      
      # Step 2: Create essential fields immediately (don't wait for migrations)
      logger.info("🔧 STEP 2: Creating essential fields for #{self.classname}")
      create_essential_fields
      
      # Step 3: Run migrations last (with better error handling)
      logger.info("🔄 STEP 3: Running migrations for #{self.classname}")
      run_migrations_safely
      
      # Step 4: Handle CCCUX setup
      logger.info("🔐 STEP 4: Setting up CCCUX for #{self.classname}")
      logger.info("🔄 Reloading model for discovery...")
      reload_new_model_for_discovery
      logger.info("🔄 Creating CCCUX permissions...")
      create_cccux_permissions_for_model
      
      logger.info("🎉 COMPLETED make_all_files for #{self.classname}")
    end

    def pos
      return 'none' unless position_parent.present?
      return 'acts_as_list' if position_parent == 'pnp'
      "acts_as_list scope: :#{position_parent.gsub('::', '_').singularize.underscore.sub(/^_/, '')}  unless Rails.env.test? ".split(' ').join('^')
    end


    def make_page_for_model
      if !self.make_page.nil? && !self.make_page.blank?
        mod = self.modyule.nil? || self.modyule.empty?  ? '' : self.modyule.underscore + '/'
        path = '/' + mod.dasherize + self.classname.underscore.dasherize.pluralize
        # path = self.make_page == 'default_model_path' ? path : self.make_page
        page = MegaBar::Page.find_or_initialize_by(path: path)
        page.assign_attributes(name: self.name + ' Model Page', path: path, make_layout_and_block: self.make_page, mega_page: self.mega_model, base_name: self.name, model_id: self.id)
        page.save unless page.id
      end
    end

    def my_constantize(class_name)
      #not in use
      unless /\A(?:::)?([A-Z]\w*(?:::[A-Z]\w*)*)\z/ =~ class_name
        raise NameError, "#{class_name.inspect} is not a valid constant name!"
      end
      Object.module_eval("::#{$1}", __FILE__, __LINE__)
    end

    def standardize_modyule
      return if self.modyule.nil? || self.modyule.empty?
      self.modyule = self.modyule.gsub('megabar', 'MegaBar')
      self.modyule = self.modyule.chomp('::').chomp(':').chomp('/').reverse.chomp('::').chomp(':').chomp('/').reverse
      self.modyule = self.modyule.gsub('-', '_')
      self.modyule = self.modyule.gsub('/', '::')
      self.modyule = self.modyule.split('::').map { | m |
        m = m.gsub('-', '_')
        m = m.classify
      }.join('::')
    end

    def standardize_classname
      self.classname = self.classname.classify
    end

    def standardize_tablename # must come after standardize_modyule
      self.tablename = self.modyule.nil? || self.modyule.empty? ?   self.classname.pluralize.underscore : self.modyule.split('::').map { | m | m = m.underscore }.join('_') + '_' + self.classname.pluralize.underscore
    end

    def make_position_field
      logger.info("🔍 make_position_field called for #{self.classname}")
      logger.info("🔍 Position field exists: #{MegaBar::Field.by_model(self.id).where(field: 'position').exists?}")
      logger.info("🔍 Position parent blank: #{self.position_parent.blank?}")
      logger.info("🔍 Position parent: '#{self.position_parent}'")
      
      unless MegaBar::Field.by_model(self.id).where(field: 'position').empty? && !self.position_parent.blank?
        logger.info("⏭️  Skipping position field creation - conditions not met")
        return
      end
      
      logger.info("📝 Creating position field for #{self.classname}")
      
      begin
        mds = find_model_displays_for_position_fields
        logger.info("🔍 Found model displays for position field: #{mds.inspect}")
        
        # Temporarily skip table validation for position field
        position_field = MegaBar::Field.new(
          model_id: self.id, 
          field: 'position', 
          tablename: self.tablename, 
          data_type: 'integer', 
          default_data_format: 'textread', 
          default_data_format_edit: 'textbox', 
          model_display_ids: mds
        )
        
        # Skip validation for position field that will be created after migration
        position_field.save!(validate: false)
        logger.info("✅ Created position field for #{self.classname} (ID: #{position_field.id})")
        
        parent_model = MegaBar::Model.find_by(
          modyule: self.position_parent.split("::")[0...-1].join("::"), 
          classname: self.position_parent.split("::").last
        )
        logger.info("🔍 Parent model found: #{parent_model ? parent_model.classname : 'nil'}")
        
        populate_positions(parent_model) if parent_model
        logger.info("✅ Position field setup completed for #{self.classname}")
        
      rescue => e
        logger.error("❌ Failed to create position field for #{self.classname}: #{e.message}")
        logger.error("❌ Error class: #{e.class}")
        logger.error("❌ Error backtrace: #{e.backtrace.first(5).join(', ')}")
      end
    end

    def find_model_displays_for_position_fields
      mds = []
      Block.find(ModelDisplay.by_model(self.id).by_action("index").pluck(:block_id)).each do |block|
        mds << block.model_displays.by_action("index").pluck(:id).first
      end
      mds
    end
    
    def populate_positions(parent_model)
      # modle = Model.find(model_id)
      # modle_name = modle.modyule ? modle.modyule + "::" + modle.classname : modle.classname
      modle_name = self.modyule ? self.modyule + "::" + self.classname : self.classname
      return unless defined?(modle_name) == 'constant' && modle_name.class == Class
      mod = modle_name.constantize
      mod.reset_column_information
      # warning: metaprogramming ahead!
      mod.distinct((parent_model.classname.underscore.downcase + '_id').to_sym).map(&parent_model.classname.underscore.downcase.to_sym).each do |parent|
        parent.send(self.classname.underscore.downcase.pluralize.to_sym).order(:id).each_with_index do |child, i|
          child.update_columns(position: i + 1)
        end
      end
    end

    # Public methods for testing and manual execution
    def create_essential_fields_after_migration
      logger.info("🔧 create_essential_fields_after_migration called for #{self.classname}")
      logger.info("🔧 Creating essential fields after migration for #{self.classname}...")
      logger.info("📋 Current fields before post-migration creation: #{MegaBar::Field.by_model(self.id).pluck(:field).join(', ')}")
      
      # Always create id field if it doesn't exist
      id_field_exists = MegaBar::Field.by_model(self.id).where(field: 'id').exists?
      logger.info("🔍 ID field exists after migration: #{id_field_exists}")
      
      unless id_field_exists
        logger.info("📝 Creating id field for #{self.classname}")
        begin
          id_field = MegaBar::Field.create!(
            model_id: self.id,
            field: 'id',
            data_type: 'integer',
            tablename: self.tablename,
            default_data_format: 'off',
            default_data_format_edit: 'off'
          )
          logger.info("✅ Created id field for #{self.classname} (ID: #{id_field.id})")
        rescue => e
          logger.error("❌ Failed to create id field: #{e.message}")
          logger.error("❌ Error class: #{e.class}")
          logger.error("❌ Error backtrace: #{e.backtrace.first(3).join(', ')}")
        end
      else
        logger.info("ℹ️  ID field already exists after migration for #{self.classname}")
      end
      
      # Always create name field if it doesn't exist
      name_field_exists = MegaBar::Field.by_model(self.id).where(field: 'name').exists?
      logger.info("🔍 Name field exists after migration: #{name_field_exists}")
      
      unless name_field_exists
        logger.info("📝 Creating name field for #{self.classname}")
        begin
          name_field = MegaBar::Field.create!(
            model_id: self.id,
            field: 'name',
            data_type: 'string',
            tablename: self.tablename,
            default_data_format: 'textbox',
            default_data_format_edit: 'textbox'
          )
          logger.info("✅ Created name field for #{self.classname} (ID: #{name_field.id})")
        rescue => e
          logger.error("❌ Failed to create name field: #{e.message}")
          logger.error("❌ Error class: #{e.class}")
          logger.error("❌ Error backtrace: #{e.backtrace.first(3).join(', ')}")
        end
      else
        logger.info("ℹ️  Name field already exists after migration for #{self.classname}")
      end
      
      # Create position field if position_parent is set
      logger.info("🔍 Calling make_position_field after migration...")
      make_position_field
      
      logger.info("✅ Essential fields created after migration for #{self.classname}")
      logger.info("📋 Final fields after post-migration creation: #{MegaBar::Field.by_model(self.id).pluck(:field).join(', ')}")
    end

    private

    def set_deterministic_id
      unless self.id
        self.id = self.class.deterministic_id(self.classname)
      end
    end

    private

    def reload_new_model_for_discovery
      return
      # Skip model reloading in test environment to avoid interfering with test setup
      return if Rails.env.test?
      
      # Force Rails to reload the newly created model for CCCUX discovery
      logger.info("🔄 Triggering model reload for CCCUX discovery...")
      
      begin
        # Get the full model class name
        model_class_name = self.modyule ? "#{self.modyule}::#{self.classname}" : self.classname
        
        # Method 1: Force Rails to reload the model file using proper paths
        model_file_name = "#{self.classname.underscore}.rb"
        
        # Look in app/models directory (where Rails models are typically stored)
        app_models_path = Rails.root.join('app', 'models')
        model_file_path = app_models_path.join(model_file_name)
        
        if File.exist?(model_file_path)
          logger.info("📁 Found model file: #{model_file_path}")
          
          # Force Rails to reload the file
          if Rails.autoloaders.respond_to?(:main)
            begin
              Rails.autoloaders.main.reload(model_file_path.to_s)
              logger.info("🔄 Reloaded via autoloaders")
            rescue => e
              logger.warn("⚠️  Autoloader reload failed: #{e.message}")
            end
          end
          
          # Also try to remove the constant and reload it
          begin
            if Object.const_defined?(model_class_name)
              Object.send(:remove_const, model_class_name)
              logger.info("🗑️  Removed existing constant: #{model_class_name}")
            end
            
            # Load the file again
            load model_file_path.to_s
            logger.info("✅ Successfully reloaded model: #{model_class_name}")
          rescue => e
            logger.warn("⚠️  Could not reload model constant: #{e.message}")
          end
        else
          logger.warn("⚠️  Model file not found at expected path: #{model_file_path}")
        end
        
        # Method 2: Force Rails to reload all models
        begin
          # Clear any cached constants
          if defined?(ApplicationRecord)
            ApplicationRecord.descendants.each do |model|
              model_name = model.name
              if model_name && Object.const_defined?(model_name)
                begin
                  Object.send(:remove_const, model_name)
                  logger.debug("🗑️  Removed cached constant: #{model_name}")
                rescue => e
                  logger.debug("Could not remove constant #{model_name}: #{e.message}")
                end
              end
            end
          end
          
          # Force Rails to reload everything
          Rails.application.eager_load! if Rails.application.config.eager_load
          logger.info("✅ Eager loading completed")
        rescue => e
          logger.warn("⚠️  Eager loading failed: #{e.message}")
        end
        
        # Method 3: Notify CCCUX about the new model
        notify_cccux_of_new_model(model_class_name)
        
      rescue => e
        logger.error("❌ Error during model reload: #{e.message}")
        logger.error(e.backtrace.join("\n"))
      end
    end

    def notify_cccux_of_new_model(model_class_name)
      # Try to notify CCCUX about the new model if it's available
      begin
        if defined?(Cccux) && Cccux.respond_to?(:model_discovery_cache_clear)
          Cccux.model_discovery_cache_clear
          logger.info("🔄 Cleared CCCUX model discovery cache")
        end
      rescue => e
        logger.debug("ℹ️  CCCUX notification not available: #{e.message}")
      end
    end

    def verify_migration_execution
      # Verify that the table was actually created
      begin
        if ActiveRecord::Base.connection.table_exists?(self.tablename)
          logger.info("✅ Migration verification: Table #{self.tablename} exists")
        else
          logger.error("❌ Migration verification: Table #{self.tablename} does not exist!")
          logger.error("⚠️  You may need to run 'rails db:migrate' manually")
        end
      rescue => e
        logger.error("❌ Migration verification failed: #{e.message}")
      end
    end

    def create_essential_fields
      logger.info("🔧 Creating essential fields for #{self.classname}...")
      logger.info("📋 Current fields for #{self.classname}: #{MegaBar::Field.by_model(self.id).pluck(:field).join(', ')}")
      
      # Skip field creation if we're in test environment (tables might not exist)
      if Rails.env.test?
        logger.info("⏭️  Skipping essential field creation in test environment")
        return
      end
      
      # Always create id field if it doesn't exist
      id_field_exists = MegaBar::Field.by_model(self.id).where(field: 'id').exists?
      logger.info("🔍 ID field exists: #{id_field_exists}")
      
      unless id_field_exists
        logger.info("📝 Creating id field for #{self.classname}")
        begin
          # Temporarily skip table validation for essential fields
          id_field = MegaBar::Field.new(
            model_id: self.id,
            field: 'id',
            data_type: 'integer',
            tablename: self.tablename,
            default_data_format: 'off',
            default_data_format_edit: 'off'
          )
          
          # Skip validation for essential fields that will be created after migration
          id_field.save!(validate: false)
          logger.info("✅ Created id field for #{self.classname} (ID: #{id_field.id})")
        rescue => e
          logger.warn("⚠️  Could not create id field (table may not exist yet): #{e.message}")
          logger.warn("⚠️  Error class: #{e.class}")
          logger.warn("⚠️  Error backtrace: #{e.backtrace.first(3).join(', ')}")
        end
      else
        logger.info("ℹ️  ID field already exists for #{self.classname}")
      end
      
      # Always create name field if it doesn't exist
      name_field_exists = MegaBar::Field.by_model(self.id).where(field: 'name').exists?
      logger.info("🔍 Name field exists: #{name_field_exists}")
      
      unless name_field_exists
        logger.info("📝 Creating name field for #{self.classname}")
        begin
          # Temporarily skip table validation for essential fields
          name_field = MegaBar::Field.new(
            model_id: self.id,
            field: 'name',
            data_type: 'string',
            tablename: self.tablename,
            default_data_format: 'textbox',
            default_data_format_edit: 'textbox'
          )
          
          # Skip validation for essential fields that will be created after migration
          name_field.save!(validate: false)
          logger.info("✅ Created name field for #{self.classname} (ID: #{name_field.id})")
        rescue => e
          logger.warn("⚠️  Could not create name field (table may not exist yet): #{e.message}")
          logger.warn("⚠️  Error class: #{e.class}")
          logger.warn("⚠️  Error backtrace: #{e.backtrace.first(3).join(', ')}")
        end
      else
        logger.info("ℹ️  Name field already exists for #{self.classname}")
      end
      
      # Create position field if position_parent is set
      logger.info("🔍 Position parent: #{self.position_parent}")
      logger.info("🔍 Position field exists: #{MegaBar::Field.by_model(self.id).where(field: 'position').exists?}")
      make_position_field
      
      logger.info("✅ Essential fields creation attempted for #{self.classname}")
      logger.info("📋 Final fields for #{self.classname}: #{MegaBar::Field.by_model(self.id).pluck(:field).join(', ')}")
    end

    def run_migrations_safely
      logger.info("🔄 run_migrations_safely called for #{self.classname}")
      
      # Skip migration execution in test environment
      if Rails.env.test?
        logger.info("⏭️  Skipping migration execution in test environment")
        return
      end
      
      logger.info("🔄 Running migrations for #{self.classname}...")
      logger.info("🔍 Table name: #{self.tablename}")
      logger.info("🔍 Table exists before migration: #{ActiveRecord::Base.connection.table_exists?(self.tablename)}")
      
      # Wait a moment for the generator to finish creating files
      logger.info("⏳ Waiting 5 seconds for generator to finish...")
      sleep(5)
      
      migration_success = false
      
      # Try multiple migration methods in order of preference
      migration_methods = [
        :try_console_migration_loading,
        :try_schema_define,
        :try_direct_execution,
        :try_rails_load_tasks,
        :try_migration_context,
        :try_system_call
      ]
      
      logger.info("🔄 Will try #{migration_methods.count} migration methods")
      
      migration_methods.each_with_index do |method, index|
        logger.info("🔄 Attempting migration method #{index + 1}/#{migration_methods.count}: #{method}")
        
        begin
          success = send(method)
          if success
            # Verify table actually exists
            table_exists_after = ActiveRecord::Base.connection.table_exists?(self.tablename)
            unless table_exists_after
              logger.warn("⚠️  Method #{method} claimed success but table doesn't exist")
              success = false  # Force trying next method
            end
          end
          
          if success
            migration_success = true
            logger.info("✅ Migration completed successfully using #{method}")
            break
          else
            logger.warn("⚠️  Migration method #{method} returned false")
          end
        rescue => e
          logger.error("❌ Migration method #{method} failed: #{e.message}")
          logger.error("❌ Error class: #{e.class}")
          logger.error("❌ Error backtrace: #{e.backtrace.first(3).join(', ')}")
          next
        end
      end
      
      logger.info("🔍 Migration success: #{migration_success}")
      logger.info("🔍 Table exists after migration: #{ActiveRecord::Base.connection.table_exists?(self.tablename)}")
      
      if migration_success
        logger.info("✅ Migration successful, verifying execution...")
        verify_migration_execution
        logger.info("✅ Creating essential fields after successful migration...")
        create_essential_fields_after_migration
      else
        logger.warn("⚠️  All migration methods failed for #{self.classname}. You may need to run 'rails db:migrate' manually.")
      end
    end

    def try_rails_load_tasks
      logger.info("🔄 try_rails_load_tasks called for #{self.classname}")
      logger.info("Trying Rails.application.load_tasks approach...")
      
      begin
        Rails.application.load_tasks
        logger.info("✅ Rails.application.load_tasks loaded successfully")
        
        # Check if there are pending migrations
        pending_migrations = ActiveRecord::MigrationContext.new(Rails.root.join('db/migrate')).migrations.select do |migration|
          !ActiveRecord::MigrationContext.new(Rails.root.join('db/migrate')).migrated.include?(migration.version)
        end
        
        if pending_migrations.any?
          logger.info("🔄 Found #{pending_migrations.count} pending migrations")
          Rake::Task['db:migrate'].invoke
          logger.info("✅ Rake::Task['db:migrate'].invoke completed")
        else
          logger.info("ℹ️  No pending migrations found")
        end
        
        true
      rescue => e
        logger.error("❌ Rails.application.load_tasks failed: #{e.message}")
        logger.error("❌ Error class: #{e.class}")
        logger.error("❌ Error backtrace: #{e.backtrace.first(3).join(', ')}")
        false
      end
    end

    def try_migration_context
      logger.info("Trying ActiveRecord::MigrationContext approach...")
      
      migration_path = Rails.env.test? ? "spec/internal/db/migrate" : "db/migrate"
      
      # Check if we're in a Rails version that supports the new API
      if ActiveRecord::MigrationContext.instance_method(:initialize).arity == 1
        migration_context = ActiveRecord::MigrationContext.new(migration_path)
      else
        migration_context = ActiveRecord::MigrationContext.new(migration_path, ActiveRecord::SchemaMigration)
      end
      
      pending_migrations = migration_context.migrations.reject { |m| migration_context.get_all_versions.include?(m.version) }
      
      if pending_migrations.any?
        logger.info("Found #{pending_migrations.count} pending migration(s), running them...")
        migration_context.migrate
        true
      else
        logger.info("ℹ️  No pending migrations found")
        true
      end
    rescue => e
      logger.error("❌ ActiveRecord::MigrationContext failed: #{e.message}")
      false
    end

    def try_system_call
      logger.info("Trying system call migration approach...")
      result = system("cd #{Rails.root} && bundle exec rails db:migrate")
      if result
        true
      else
        logger.error("❌ System call migration failed")
        false
      end
    end

    def try_direct_execution
      logger.info("Trying direct migration execution...")
      
      # Find the most recent migration file for this table
      migration_files = Dir.glob(File.join(Rails.root, 'db', 'migrate', "*create_#{self.tablename}.rb"))
      if migration_files.any?
        latest_migration = migration_files.sort.last
        logger.info("Found migration file: #{latest_migration}")
        
        # Load and execute the migration directly
        load latest_migration
        migration_class_name = File.basename(latest_migration, '.rb').split('_').drop(1).map(&:camelize).join
        migration_class = migration_class_name.constantize
        
        # Check if migration has already been run
        unless ActiveRecord::Base.connection.table_exists?(self.tablename)
          logger.info("Executing migration: #{migration_class_name}")
          migration_instance = migration_class.new
          migration_instance.up
          true
        else
          logger.info("ℹ️  Table #{self.tablename} already exists, skipping migration")
          true
        end
      else
        logger.warn("⚠️  No migration file found for table #{self.tablename}")
        false
      end
    rescue => e
      logger.error("❌ Direct migration execution failed: #{e.message}")
      false
    end

    def try_console_migration_loading
      logger.info("🔄 try_console_migration_loading called for #{self.classname}")
      logger.info("Trying Rails console migration loading approach...")
      
      migration_file = Dir.glob("db/migrate/*_create_#{self.tablename}.rb").first
      logger.info("🔍 Found migration file: #{migration_file}")
      
      return false unless migration_file
      
      begin
        require File.expand_path(migration_file)
        class_name = migration_file.split('/').last.gsub('.rb', '').gsub(/^\d+_/, '').camelize
        migration_class = class_name.constantize
        
        # Use Rails' MigrationContext instead of direct instantiation
        migration_context = ActiveRecord::MigrationContext.new("db/migrate")
        migration_context.up
        
        true
      rescue => e
        logger.error("❌ Console migration loading failed: #{e.message}")
        logger.error("❌ Error class: #{e.class}")
        logger.error("❌ Error backtrace: #{e.backtrace.first(3).join(', ')}")
        false
      end
    end

    def try_schema_define
      logger.info("🔄 try_schema_define called for #{self.classname}")
      logger.info("Trying ActiveRecord::Schema.define approach...")
      
      begin
        ActiveRecord::Schema.define do
          create_table self.tablename.to_sym do |t|
            t.string :name
            t.integer :position
            t.timestamps
          end
        end
        logger.info("✅ Schema define completed successfully")
        true
      rescue => e
        logger.error("❌ Schema define failed: #{e.message}")
        logger.error("❌ Error class: #{e.class}")
        logger.error("❌ Error backtrace: #{e.backtrace.first(3).join(', ')}")
        false
      end
    end

    def create_cccux_permissions_for_model
      # Skip if CCCUX is not available
      return unless defined?(Cccux::Ability)
      
      logger.info("🔐 Creating CCCUX permissions for #{self.classname}...")
      
      begin
        # Get the model class name - only add :: if there's actually a module
        model_class_name = if self.modyule && !self.modyule.empty?
          "#{self.modyule}::#{self.classname}"
        else
          self.classname
        end
        
        logger.info("📝 Using model class name: #{model_class_name}")
        
        # Create CRUD permissions for the model
        crud_actions = ['read', 'create', 'update', 'destroy']
        
        # Add MegaBar-specific custom actions
        megabar_actions = ['administer_page', 'administer_block', 'move']
        
        # Combine all actions
        all_actions = crud_actions + megabar_actions
        permissions_created = []
        
        all_actions.each do |action|
          permission = Cccux::AbilityPermission.find_or_create_by(
            subject: model_class_name,
            action: action
          )
          permissions_created << permission
          logger.info("✅ Created permission: #{action} #{model_class_name}")
        end
        
        # Find or create the Mega Role
        mega_role = Cccux::Role.find_or_create_by(name: 'Mega Role') do |role|
          role.description = 'Full access to all MegaBar functionality'
          logger.info("✅ Created Mega Role")
        end
        
        logger.info("🔍 Found Mega Role: #{mega_role.id}")
        
        # Add all permissions to the Mega Role
        permissions_created.each do |permission|
          role_ability = Cccux::RoleAbility.find_or_create_by(
            role: mega_role,
            ability_permission: permission,
            context: 'global',
            owned: false
          )
          if role_ability.persisted?
            logger.info("✅ Added #{permission.action} permission to Mega Role")
          else
            logger.error("❌ Failed to add #{permission.action} permission to Mega Role: #{role_ability.errors.full_messages.join(', ')}")
          end
        end
        
        # Store message for display in controller
        @cccux_setup_message = "🎉 Model '#{self.name}' created successfully! " +
                              "Only users with 'Mega Role' can access it. " +
                              "Visit <a href='/cccux/roles'>CCCUX Roles page</a> to add these permissions to other roles."
        
        # Try to add flash message if we're in a controller context
        if defined?(flash)
          flash[:notice] = @cccux_setup_message
        end
        
        logger.info("✅ CCCUX permissions setup completed for #{self.classname}")
        
      rescue => e
        logger.error("❌ Failed to create CCCUX permissions for #{self.classname}: #{e.message}")
        logger.error(e.backtrace.join("\n"))
      end
    end

    def cccux_setup_message
      @cccux_setup_message
    end
  end
end
