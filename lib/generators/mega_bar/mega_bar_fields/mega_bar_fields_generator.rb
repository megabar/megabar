module MegaBar
  class MegaBarFieldsGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)
    argument :tablename, type: :string
    argument :fieldname, type: :string
    argument :fieldtype, type: :string
    
    def generate_migration
      generate 'migration add_' + fieldname + '_to_' + tablename  + ' ' + fieldname + ':' + fieldtype
      generate 'migration add_' + fieldname + '_to_tmp_' + tablename  + ' ' + fieldname + ':' + fieldtype  if tablename.start_with?('mega_bar')      
    end
    
  end
end