# MegaBar Rails Application Template
# Usage: rails new myapp -m megabar_app_template.rb

# Add megabar gem to Gemfile
gem 'mega_bar', path: '../megabar'

# Run bundle install
run 'bundle install'

# Run megabar engine initialization
rails_command 'mega_bar:engine_init'

puts "🎉 MegaBar application created successfully!"
puts "Your app is ready with MegaBar installed and configured."
puts "Run 'rails server' to start your application." 