Rails.application.configure do
  # Configure the migration path for tests
  config.paths['db/migrate'] = [File.expand_path('../db/migrate', __FILE__)]
  
  # Test environment settings
  config.cache_classes = false
  config.action_controller.perform_caching = false
  config.action_dispatch.show_exceptions = false
  config.action_controller.allow_forgery_protection = false
  config.active_support.deprecation = :stderr
end 