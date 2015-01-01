module MegaBar
  class Engine < ::Rails::Engine
    isolate_namespace MegaBar


    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
    end
    ### taskrabbit: http://tech.taskrabbit.com/blog/2014/02/11/rails-4-engines/
    ### http://pivotallabs.com/leave-your-migrations-in-your-rails-engines/


  end
end
