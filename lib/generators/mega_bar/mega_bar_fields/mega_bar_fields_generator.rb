module MegaBar
  class MegaBarFieldsGenerator < Rails::Generators::Base
    require 'fileutils'
    source_root File.expand_path('../templates', __FILE__)
    argument :tablename, type: :string
    argument :fieldname, type: :string
    argument :fieldtype, type: :string
    
    def generate_migration
      if Rails.env.test?
        # Generate migration in test-specific directory
        migration_name = "add_#{fieldname}_to_#{tablename}"
        migration_file = generate_field_migration_file(migration_name, fieldname, fieldtype)
        puts "Migration created in test directory: #{migration_file}"
      else
        generate 'migration add_' + fieldname + '_to_' + tablename  + ' ' + fieldname + ':' + fieldtype
        # REVOLUTIONARY CHANGE: No more tmp table migrations needed with deterministic IDs!
        # generate 'migration add_' + fieldname + '_to_mega_bar_tmp_' + tablename[9..-1]  + ' ' + fieldname + ':' + fieldtype  if tablename.start_with?('mega_bar')      
      end
    end

    private

    def generate_field_migration_file(migration_name, fieldname, fieldtype)
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
            add_column :#{tablename}, :#{fieldname}, :#{fieldtype}
          end
          
          def down
            remove_column :#{tablename}, :#{fieldname}
          end
        end
      RUBY
      
      File.write(migration_file, migration_content)
      migration_file
    end
  end
end