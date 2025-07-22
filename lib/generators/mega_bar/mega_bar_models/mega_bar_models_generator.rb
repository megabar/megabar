module MegaBar
  class MegaBarModelsGenerator < Rails::Generators::Base
    require 'fileutils'
    # require 'byebug'
    source_root File.expand_path('../templates', __FILE__)
    argument :modyule, type: :string
    argument :classname, type: :string
    argument :model_id, type: :string
    argument :pos, type: :string
    @@notices = []

    # in generators, all public methods are run. Weird, huh?
    def create_controller_file
      # Check if the controller class already exists
      full_controller_class_name = the_module_name ? "#{the_module_name}::#{the_controller_name}" : the_controller_name
      
      begin
        full_controller_class_name.constantize
        @@notices << "Controller #{full_controller_class_name} already exists, skipping controller file creation"
        return
      rescue NameError
        # Controller doesn't exist, proceed with creation
      end
      
      @@notices << "You will have to copy your controller manually over to the megabar gem" if gem_path == '' && modyule == 'MegaBar'
      template 'generic_controller.rb', "#{gem_path}#{the_controller_file_path}#{the_controller_file_name}.rb"
    end
    
    def create_model_file
      # Check if the model class already exists
      full_class_name = the_module_name ? "#{the_module_name}::#{classname}" : classname
      
      begin
        full_class_name.constantize
        @@notices << "Model #{full_class_name} already exists, skipping model file creation"
        return
      rescue NameError
        # Class doesn't exist, proceed with creation
      end
      
      template 'generic_model.rb', "#{gem_path}#{the_model_file_path}#{the_model_file_name}.rb"
      @@notices <<  "You will have to copy your model files manually over to the megabar gem" if gem_path == '' && modyule == 'MegaBar'
    end
    
    def generate_migration
      # Check if the table already exists
      # In test environment, skip the table check since we're in the engine context
      if Rails.env.test?
        # Generate migration in test-specific directory
        migration_name = "create_#{the_table_name}"
        migration_file = generate_migration_file(migration_name)
        @@notices << "Migration created in test directory: #{migration_file}"
      else
        # In production, check if table exists
        if ActiveRecord::Base.connection.table_exists?(the_table_name)
          @@notices << "Table #{the_table_name} already exists, skipping migration creation"
          return
        end
        
        if the_module_name
          generate 'migration create_' + the_table_name
          @@notices <<  "You will have to copy your Migrations manually over to the megabar gem"
        else
          generate 'migration create_' + the_table_name
        end
      end
    end

    def create_controller_spec_file
      # Check if the spec file already exists
      spec_file_path = "#{gem_path}#{the_controller_spec_file_path}#{the_controller_spec_file_name}.rb"
      if File.exist?(spec_file_path)
        @@notices << "Controller spec file already exists, skipping spec file creation"
        return
      end
      
      template 'generic_controller_spec.rb', spec_file_path
      @@notices <<  "You will have to copy the spec file yourself manually to the megabar repo's spec/controllers directory" if gem_path == '' && modyule == 'MegaBar'
    end

    def create_factory
      # Check if the factory file already exists
      factory_file_path = "#{gem_path}#{the_factory_file_path}#{the_model_file_name}.rb"
      if File.exist?(factory_file_path)
        @@notices << "Factory file already exists, skipping factory file creation"
        return
      end
      
      @@notices <<  "You will have to copy the factory file yourself manually to the megabar repo's spec/internal/factories directory" if gem_path == '' && modyule == 'MegaBar'
      template 'generic_factory.rb', factory_file_path
    end

    def write_notices
      # todo .. take @@notices and write it to a db? or a file? hmm..
    end


    private

    def gem_path
      return '' if Rails.env == 'test'
      File.directory?(Rails.root + '../megabar/')  && modyule == 'MegaBar' ? Rails.root + '../megabar/' : ''
    end

    def position
      return '' if  pos == 'none'
      pos.split('^').join(' ')
    end
    def the_controller_file_name
      classname.pluralize.underscore + "_controller"
    end

    def the_controller_file_path
      if the_module_name
        'app/controllers/' + the_module_path + '/'
      else
        'app/controllers/'
      end
    end

    def the_controller_name
      classname.pluralize + 'Controller'
    end

    def the_controller_spec_file_name
      classname.pluralize.underscore + "_controller_spec"
    end

    def the_controller_spec_file_path
      if the_module_name && gem_path == ''
        'spec/controllers/' + the_module_path + '/'
      else
        'spec/controllers/'
      end
    end

    def the_factory_file_path
      if Rails.env.test?
        'spec/internal/factories/'
      elsif the_module_name == 'MegaBar'
        'spec/internal/factories/'
      else
        'spec/factories/'
      end
    end

    def the_model_file_name
      classname.to_s.singularize.underscore
    end

    def the_model_file_path
      if the_module_name
        'app/models/' + the_module_path + '/'
      else
        'app/models/'
      end
    end

    def the_module_array
      the_module_name.nil? || the_module_name.empty? ? [] : the_module_name.split('::')
    end

    def the_module_name
      modyule == 'no_mod' ? nil : modyule
    end

    def the_module_path
      return '' if modyule == 'no_mod'
      the_module_name.split('::').map { |m| m.underscore }.join('/')
    end

    def the_route_name
      classname.pluralize.underscore
    end

    def the_route_path
       the_route_name.include?('_') ? the_route_name.gsub('_', '-') : the_route_name
    end

    def the_table_name
      prefix = the_module_name.nil? || the_module_name.empty? ? '' : the_module_name.split('::').map { | m | m.underscore }.join('_') + '_'
      prefix + classname.pluralize.underscore
    end

    def use_route
      return '' if the_module_name.nil? || the_module_name.empty?
      the_module_name.split('::').size == 1 ? 'use_route: ' + the_module_name + ', ' : '' #else might could be improved for other modules.
    end

    def generate_migration_file(migration_name)
      # Create migration in test-specific directory
      timestamp = Time.now.strftime('%Y%m%d%H%M%S')
      migration_filename = "#{timestamp}_#{migration_name}.rb"
      migration_path = File.expand_path('../../../../../spec/internal/db/migrate', __FILE__)
      
      # Ensure the directory exists
      FileUtils.mkdir_p(migration_path)
      
      # Create the migration file
      migration_file = File.join(migration_path, migration_filename)
      
      # Generate migration content
      migration_content = <<~RUBY
        class #{migration_name.classify} < ActiveRecord::Migration[#{Rails.version.split('.')[0..1].join('.')}]
          def up
            create_table :#{the_table_name} do |t|
              t.timestamps
            end
          end
          
          def down
            drop_table :#{the_table_name}
          end
        end
      RUBY
      
      File.write(migration_file, migration_content)
      migration_file
    end
  end
end
