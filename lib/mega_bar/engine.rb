module MegaBar
  class Engine < ::Rails::Engine
    isolate_namespace MegaBar
    require 'seed_dump'


    initializer :append_migrations do |app|
      unless app.root.to_s.match root.to_s
        config.paths["db/migrate"].expanded.each do |expanded_path|
          app.config.paths["db/migrate"] << expanded_path
        end
      end
    end
    
    initializer "model_core.factories", :after => "factory_girl.set_factory_paths" do
      FactoryGirl.definition_file_paths << File.expand_path('../../../spec/factories', __FILE__) if defined?(FactoryGirl)
    end
    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
      g.assets false
      g.helper false
    end
    ### taskrabbit: http://tech.taskrabbit.com/blog/2014/02/11/rails-4-engines/
    ### http://pivotallabs.com/leave-your-migrations-in-your-rails-engines/
 
    config.action_view.logger = nil

  end
end
