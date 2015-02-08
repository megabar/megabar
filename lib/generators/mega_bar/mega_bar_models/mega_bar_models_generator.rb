module MegaBar
  class MegaBarModelsGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)
    argument :modul, type: :string
    argument :classname, type: :string
    argument :model_id, type: :string
    @@notices = []
    
    # in generators, all public methods are run. Weird, huh?

    def create_controller_file
      byebug
      @@notices << "You will have to copy your controller manually over to the megabar gem" if gem_path == '' && modul == 'MegaBar'
      template 'generic_controller.rb', "#{gem_path}#{the_controller_file_path}#{the_controller_file_name}.rb"
    end
    def create_model_file
      template 'generic_model.rb', "#{gem_path}#{the_model_file_path}#{the_model_file_name}.rb"
      @@notices <<  "You will have to copy your model files manually over to the megabar gem" if gem_path == '' && modul == 'MegaBar'
      template "generic_model.rb", "#{gem_path}#{the_model_file_path}tmp_#{the_model_file_name}.rb" if modul == 'MegaBar'
    end
    def generate_migration
      if the_module_name
        generate 'migration create_' + the_table_name + ' created_at:datetime updated_at:datetime'
        generate 'migration create_' + 'mega_bar_tmp_' + classname.underscore.downcase.pluralize + ' created_at:datetime updated_at:datetime' if modul == 'MegaBar'
        @@notices <<  "You will have to copy your Migrations manually over to the megabar gem"
      else 
        generate 'migration create_' + the_table_name + ' created_at:datetime updated_at:datetime'
      end
    end
    def route
      line = '  ##### MEGABAR END'
      text = File.read(gem_path + 'config/routes.rb')
      path = the_route_name.include?('_') ? "path: '/" + the_route_name.gsub('_', '-') + "', " : '' # no underscores!
      route_text = '  resources :' + the_route_name + ', ' + path + ' defaults: {model_id: ' + model_id + "}\n #{line}\n"
      new_contents = text.gsub( /(#{Regexp.escape(line)})/mi, route_text)
      # To write changes to the file, use:
      File.open(gem_path + 'config/routes.rb', "w") {|file| file.puts new_contents } unless gem_path == '' && modul == 'MegaBar'
      @@notices <<  "You will have to add the route yourself manually to the megabar route file: #{route_text}" if gem_path == '' && modul == 'MegaBar'
     
    end

    def create_controller_spec_file
      byebug
      template 'generic_controller_spec.rb', "#{gem_path}#{the_controller_spec_file_path}#{the_controller_spec_file_name}.rb"
      @@notices <<  "You will have to copy the spec file yourself manually to the megabar repo's spec/controllers directory" if gem_path == '' && modul == 'MegaBar'
    end

    def create_factory
      byebug
      @@notices <<  "You will have to copy the factory file yourself manually to the megabar repo's spec/internal/factories directory" if gem_path == '' && modul == 'MegaBar'
      template 'generic_factory.rb', "#{gem_path}#{the_factory_file_path}#{the_model_file_name}.rb"
    end

    def write_notices
      # todo .. take @@notices and write it to a db? or a file? hmm..
    end


    private

    def gem_path
      File.directory?(Rails.root + '../megabar/')  && modul == 'MegaBar' ? Rails.root + '../megabar/' : ''
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
      if the_module_name == 'MegaBar'
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

    def the_module_name
      modul == 'no_mod' ? nil : modul
    end

    def the_module_path
      return '' if modul == 'no_mod'
      the_module_name.split('::').map { |m| m.underscore }.join('/')
    end

    def the_route_name
      classname.pluralize.underscore
    end

    def the_route_path
       the_route_name.include?('_') ? the_route_name.gsub('_', '-') : 'the_route_name'
    end

    def the_table_name
      prefix = the_module_name.empty? ? '' : the_module_name.split('::').map { | m | m.underscore }.join('_') + '_'
      prefix + classname.pluralize.underscore
    end

    def use_route
      the_module_name.split('::').size == 1 ? 'use_route: ' + the_module_name + ', ' : '' #else might could be improved for other modules.
    end
  end
end