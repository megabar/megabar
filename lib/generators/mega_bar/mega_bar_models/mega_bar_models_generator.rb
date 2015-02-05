module MegaBar
  class MegaBarModelsGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)
    argument :filename, type: :string
    argument :model_id, type: :string
    
    # in generators, all public methods are run. Weird, huh?

    def create_controller_file
      template 'generic_controller.rb', "#{the_controller_file_path}#{the_controller_file_name}.rb"
    end
    def create_model_file
       template 'generic_model.rb', "#{the_model_file_path}#{the_model_file_name}.rb"
       if the_module_name
         template "generic_model.rb", "Tmp#{the_model_file_path}#{the_model_file_name}.rb"
       end
    end
    def generate_migration
      if the_module_name
        generate 'migration create_' + the_module_name + '_' + the_table_name + ' created_at:datetime updated_at:datetime'
        generate 'migration create_' + the_module_name + '_tmp_' + the_table_name + ' created_at:datetime updated_at:datetime'        
        # generate 'migration create_tmp_' + the_module_name + '_' + the_table_name + ' created_at:datetime updated_at:datetime'
      else 
        generate 'migration create_' + the_table_name + ' created_at:datetime updated_at:datetime'
      end
    end
    def route
      line = '  ##### MEGABAR END'
      text = File.read('config/routes.rb')
      path = the_route_name.include?('_') ? "path: '/" + the_route_name.gsub('_', '-') + "', " : ''
      new_contents = text.gsub( /(#{Regexp.escape(line)})/mi, '  resources :' + the_route_name + ', ' + path + ' defaults: {model_id: ' + model_id + "}\n #{line}\n")
      # To write changes to the file, use:
      File.open('config/routes.rb', "w") {|file| file.puts new_contents }
    end

    def create_controller_spec_file
      template 'generic_controller_spec.rb', "#{the_controller_spec_file_path}#{the_controller_spec_file_name}.rb"
    end

    def create_factory
      template 'generic_factory.rb', "#{the_factory_file_path}#{the_model_file_name}.rb"
    end

    private

    def the_controller_file_name
      the_file_name.pluralize.underscore + "_controller"
    end

    def the_controller_file_path
      if the_module_name
        'app/controllers/' + the_module_name.underscore + '/'
      else
        'app/controllers/'
      end
    end
     
    def the_controller_name
      the_file_name.classify.pluralize + 'Controller'
    end 

    def the_controller_spec_file_name
      the_file_name.pluralize.underscore + "_controller_spec"
    end

    def the_controller_spec_file_path
      if the_module_name
        'spec/controllers/' + the_module_name.underscore + '/'
      else
        'spec/controllers/'
      end
    end
    
    def the_factory_file_path
      if the_module_name
        'spec/internal/factories/'
      else
        'spec/factories/'
      end
    end

    def the_file_name
       if filename.include? '::' 
        return filename[filename.index('::')+2..-1] # nested modules not supported yet.
      else
        return filename
      end
    end

    def the_model_file_name
      the_file_name.to_s.singularize.underscore
    end

    def the_model_file_path
      if the_module_name
        'app/models/' + the_module_name.underscore + '/'
      else
        'app/models/'
      end
    end

    def the_model_name
      the_file_name.classify
    end

    def the_module_name
      if filename.include? '::'
        return filename[0..filename.index('::')-1] 
      else
        return nil
      end
    end
  
    def the_route_name
      the_file_name.pluralize.underscore
    end

    def the_route_path
       the_route_name.include?('_') ? the_route_name.gsub('_', '-') : 'the_route_name'
    end

    def the_table_name
      the_file_name.pluralize
    end
    def use_route
      the_module_name ? 'use_route: :mega_bar, ' : ''
    end
  end
end