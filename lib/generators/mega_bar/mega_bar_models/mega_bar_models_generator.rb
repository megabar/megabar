module MegaBar
  class MegaBarModelsGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)
    argument :filename, type: :string
    argument :model_id, type: :string
    
    # in generators, all public methods are run. Weird, huh?

    def create_controller_file
      template "generic_controller.rb", "#{the_controller_file_name}.rb"
      if the_module_name
        # template "generic_controller.rb", "tmp_#{the_controller_file_name}.rb"
      end
    end
     def create_model_file
       template "generic_model.rb", "#{the_model_file_name}"
       if the_module_name
        # template "generic_model.rb", "Tmp#{the_model_file_name}.rb"
      end
    end
    def generate_migration
      if the_module_name
        generate 'migration create_' + the_module_name + '_' + the_table_name + ' created_at:datetime updated_at:datetime'
        # generate 'migration create_tmp_' + the_module_name + '_' + the_table_name + ' created_at:datetime updated_at:datetime'
      else 
        generate 'migration create_' + the_table_name + ' created_at:datetime updated_at:datetime'
      end

    end
    def route
      line = '  ##### MEGABAR END'
      text = File.read('config/routes.rb')
      byebug
      new_contents = text.gsub( /(#{Regexp.escape(line)})/mi, 'resources :' + the_route_name + ", defaults: {model_id: model_id}\n #{line}\n")
      # To write changes to the file, use:
      File.open('config/routes.rb', "w") {|file| file.puts new_contents }
    end

    private

    def the_file_name
       if filename.include? '::' 
        return  filename[filename.index('::')+2..-1]
      else
        return  filename
      end
    end

    def the_model_file_name
      if the_module_name
        'app/models/' + the_module_name.underscore + '/' + the_file_name.to_s.singularize.underscore + '.rb'
      else
        'app/models/' + the_file_name.to_s.singularize.underscore + '.rb'
      end
    end

    def the_model_name
      the_file_name.classify
    end

    def the_controller_file_name
      if the_module_name
        'app/controllers/' + the_module_name.underscore + '/' + the_file_name.pluralize.underscore + "_controller"
      else
        'app/controllers/' + the_file_name.pluralize.underscore + "_controller"
      end
    end

    def the_controller_name
      the_file_name.classify.pluralize + 'Controller'
    end 

    def the_table_name
      the_file_name.pluralize
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

  end
end