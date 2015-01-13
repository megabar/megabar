module MegaBar
  class Engine < ::Rails::Engine
    isolate_namespace MegaBar
    require 'seed_dump'

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
      g.assets false
      g.helper false
    end
    ### taskrabbit: http://tech.taskrabbit.com/blog/2014/02/11/rails-4-engines/
    ### http://pivotallabs.com/leave-your-migrations-in-your-rails-engines/


  end
end
