module MegaBar
  class MegaBarGenerator < Rails::Generators::Base
  def create_scaffold
    create_file "config/initializers/initializer.rb", "# Add initialization content here"
  end
end