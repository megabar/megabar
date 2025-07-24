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
      make_position_field
      # generate 'active_record:model', [self.classname]]
      logger.info("creating scaffold for " + self.classname + 'via: ' + 'rails g mega_bar:mega_bar ' + self.classname + ' ' + self.id.to_s)
      mod = self.modyule.nil? || self.modyule.empty?  ? 'no_mod' : self.modyule

      # Generate model files and migrations using system call (most reliable for production)
      logger.info("Invoking MegaBar generator for #{self.classname}...")
      generator_command = "rails g mega_bar:mega_bar_models #{mod} #{self.classname} #{self.id.to_s} #{pos}"
      logger.info("Generator command: #{generator_command}")
      
      generator_result = system(generator_command)
      if generator_result
        logger.info("✅ Generator completed successfully for #{self.classname}")
      else
        logger.error("❌ Generator failed for #{self.classname}")
        # Try with bundle exec as fallback
        bundle_command = "bundle exec #{generator_command}"
        logger.info("Trying with bundle exec: #{bundle_command}")
        bundle_result = system(bundle_command)
        if bundle_result
          logger.info("✅ Generator completed successfully with bundle exec for #{self.classname}")
        else
          logger.error("❌ Generator failed even with bundle exec for #{self.classname}")
        end
      end
      
      # Run migrations using Rails internal methods (more reliable than system calls)
      logger.info("Running migrations for #{self.classname}...")
      
      # Skip migration execution in test environment to avoid interfering with test setup
      if Rails.env.test?
        logger.info("⏭️  Skipping migration execution in test environment")
        return
      end
      
      # Wait a moment for the generator to finish creating files
      sleep(1)
      
      begin
        # Method 1: Try to use Rails.application.load_tasks approach (most compatible)
        logger.info("Trying Rails.application.load_tasks approach...")
        Rails.application.load_tasks
        Rake::Task['db:migrate'].invoke
        logger.info("✅ Migrations completed successfully for #{self.classname}")
        
      rescue => e
        logger.error("❌ Rails.application.load_tasks failed for #{self.classname}: #{e.message}")
        
        begin
          # Method 2: Try ActiveRecord::MigrationContext with proper error handling
          logger.info("Trying ActiveRecord::MigrationContext approach...")
          
          # Use the correct migration path based on environment
          migration_path = Rails.env.test? ? "spec/internal/db/migrate" : "db/migrate"
          
          # Check if we're in a Rails version that supports the new API
          if ActiveRecord::MigrationContext.instance_method(:initialize).arity == 1
            # Newer Rails version (single parameter)
            migration_context = ActiveRecord::MigrationContext.new(migration_path)
          else
            # Older Rails version (two parameters)
            migration_context = ActiveRecord::MigrationContext.new(migration_path, ActiveRecord::SchemaMigration)
          end
          
          pending_migrations = migration_context.migrations.reject { |m| migration_context.get_all_versions.include?(m.version) }
          
          if pending_migrations.any?
            logger.info("Found #{pending_migrations.count} pending migration(s), running them...")
            migration_context.migrate
            logger.info("✅ Migrations completed successfully for #{self.classname}")
          else
            logger.info("ℹ️  No pending migrations found for #{self.classname}")
          end
          
        rescue => e2
          logger.error("❌ ActiveRecord::MigrationContext failed for #{self.classname}: #{e2.message}")
          
          # Method 3: System call as last resort (but skip in test environment)
          if Rails.env.test?
            logger.info("⏭️  Skipping system call migration in test environment")
          else
            logger.info("Trying system call migration approach...")
            result = system("cd #{Rails.root} && bundle exec rails db:migrate")
            if result
              logger.info("✅ System call migration succeeded for #{self.classname}")
            else
              logger.error("❌ System call migration failed for #{self.classname}")
            end
          end
        end
      end
      
      # Method 4: Direct migration execution as final fallback
      begin
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
            logger.info("✅ Direct migration execution succeeded for #{self.classname}")
          else
            logger.info("ℹ️  Table #{self.tablename} already exists, skipping migration")
          end
        else
          logger.warn("⚠️  No migration file found for table #{self.tablename}")
        end
      rescue => e3
        logger.error("❌ Direct migration execution failed for #{self.classname}: #{e3.message}")
      end
      
      # Verify migration was executed successfully
      verify_migration_execution
      
      # Trigger model reloading for CCCUX discovery
      reload_new_model_for_discovery
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
      return unless MegaBar::Field.by_model(self.id).where(field: 'position').empty? && !self.position_parent.blank?
      mds = find_model_displays_for_position_fields
      Field.create(model_id: self.id, field: 'position', tablename: self.tablename, data_type: 'integer', default_data_format: 'textread', default_data_format_edit: 'textbox', model_display_ids: mds)
      parent_model = MegaBar::Model.find_by(modyule: self.position_parent.split("::")[0...-1].join("::"), classname: self.position_parent.split("::").last)
      populate_positions(parent_model)
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

    private

    def set_deterministic_id
      unless self.id
        self.id = self.class.deterministic_id(self.classname)
      end
    end

    private

    def reload_new_model_for_discovery
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
            Rails.autoloaders.main.reload(model_file_path.to_s)
            logger.info("🔄 Reloaded via autoloaders")
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
  end
end
