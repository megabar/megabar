module MegaBar
  class MegaBarModelsGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)
    argument :mod, type: :string
    argument :filename, type: :string
    argument :model_id, type: :string
    @@notices = []
    
    # in generators, all public methods are run. Weird, huh?

    def create_controller_file
      @@notices << "You will have to copy your controller manually over to the megabar gem" if gem_path == '' and the_module_name == 'MegaBar'
      template 'generic_controller.rb', "#{gem_path}#{the_controller_file_path}#{the_controller_file_name}.rb"
    end
    def create_model_file
       template 'generic_model.rb', "#{gem_path}#{the_model_file_path}#{the_model_file_name}.rb"
       @@notices <<  "You will have to copy your model files manually over to the megabar gem" if gem_path == '' and the_module_name == 'MegaBar'
       if the_module_name
         template "generic_model.rb", "#{gem_path}Tmp#{the_model_file_path}#{the_model_file_name}.rb"
       end
    end
    def generate_migration
      if the_module_name
        generate 'migration create_' + the_module_name + '_' + the_table_name + ' created_at:datetime updated_at:datetime'
        generate 'migration create_' + the_module_name + '_tmp_' + the_table_name + ' created_at:datetime updated_at:datetime'   
        @@notices <<  "You will have to copy your Migrations manually over to the megabar gem"
        # generate 'migration create_tmp_' + the_module_name + '_' + the_table_name + ' created_at:datetime updated_at:datetime'
      else 
        generate 'migration create_' + the_table_name + ' created_at:datetime updated_at:datetime'
      end
    end
    def route
      line = '  ##### MEGABAR END'
      text = File.read(gem_path + 'config/routes.rb')
      path = the_route_name.include?('_') ? "path: '/" + the_route_name.gsub('_', '-') + "', " : ''
      route_text = '  resources :' + the_route_name + ', ' + path + ' defaults: {model_id: ' + model_id + "}\n #{line}\n"
      new_contents = text.gsub( /(#{Regexp.escape(line)})/mi, route_text)
      # To write changes to the file, use:
      File.open(gem_path + 'config/routes.rb', "w") {|file| file.puts new_contents } unless gem_path == '' and the_module_name == 'MegaBar'
      @@notices <<  "You will have to add the route yourself manually to the megabar route file: #{route_text}" if gem_path == '' and the_module_name == 'MegaBar'
     
    end

    def create_controller_spec_file
      template 'generic_controller_spec.rb', "#{gem_path}#{the_controller_spec_file_path}#{the_controller_spec_file_name}.rb"
      @@notices <<  "You will have to copy the spec file yourself manually to the megabar repo's spec/controllers directory" if gem_path == '' and the_module_name == 'MegaBar'
    end

    def create_factory
      @@notices <<  "You will have to copy the factory file yourself manually to the megabar repo's spec/internal/factories directory" if gem_path == '' and the_module_name == 'MegaBar'
      template 'generic_factory.rb', "#{gem_path}#{the_factory_file_path}#{the_model_file_name}.rb"
    end

    def write_notices
      # todo .. take @@notices and write it to a db? or a file? hmm..
    end


    private

    def gem_path
      File.directory?(Rails.root + '../megabar/')  && the_module_name == 'MegaBar' ? Rails.root + '../megabar/' : ''
    end

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
      if mod == 'no_mod'
         return nil
      else
        (mod.downcase == 'megabar' || mod.downcase == 'mega_bar') ? 'MegaBar' : mod
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