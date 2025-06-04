#!/bin/bash

# MegaBar App Creator Script
# Usage: ./create_megabar_app.sh [app_name]

if [ -z "$1" ]; then
    echo "🚀 MegaBar App Creator"
    echo "====================="
    echo ""
    read -p "Enter the name for your new MegaBar app: " APP_NAME
    
    if [ -z "$APP_NAME" ]; then
        echo "❌ App name cannot be empty!"
        exit 1
    fi
else
    APP_NAME=$1
fi

echo ""
echo "🚀 Creating new MegaBar application: $APP_NAME"
echo "================================================"

# Ask for database preference
echo ""
echo "📦 Choose your database:"
echo "1) SQLite (default)"
echo "2) PostgreSQL"
read -p "Enter your choice [1]: " DB_CHOICE

DB_OPTION=""
if [ "$DB_CHOICE" = "2" ]; then
    DB_OPTION="--database=postgresql"
    echo "✅ Selected PostgreSQL database"
else
    echo "✅ Selected SQLite database"
fi

# Create Rails app
rails new $APP_NAME  $DB_OPTION

# Navigate to app directory
cd $APP_NAME

# Configure development settings for MegaBar compatibility
echo "🔧 Configuring development settings for MegaBar..."
sed -i '' 's/config.action_view.annotate_rendered_view_with_filenames = true/config.action_view.annotate_rendered_view_with_filenames = false/' config/environments/development.rb

# Add megabar gem
echo 'gem "mega_bar", path: "../megabar"' >> Gemfile

# Add byebug gem to development and test groups
echo -e '\ngroup :development, :test do\n  gem "byebug"\nend\n' >> Gemfile

# Install dependencies
bundle install

# Initialize MegaBar
bundle exec rake mega_bar:engine_init

echo ""
echo "🎉 SUCCESS! MegaBar application '$APP_NAME' created!"
echo "📁 Navigate to: cd $APP_NAME"
echo "🚀 Start server: rails server"
echo "🌐 Visit: http://localhost:3000" 