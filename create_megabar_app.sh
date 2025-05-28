#!/bin/bash

# MegaBar App Creator Script
# Usage: ./create_megabar_app.sh app_name

if [ -z "$1" ]; then
    echo "Usage: $0 <app_name>"
    echo "Example: $0 my_new_app"
    exit 1
fi

APP_NAME=$1

echo "🚀 Creating new MegaBar application: $APP_NAME"
echo "================================================"

# Create Rails app
rails new $APP_NAME --skip-git

# Navigate to app directory
cd $APP_NAME

# Add megabar gem
echo 'gem "mega_bar", path: "../megabar"' >> Gemfile

# Install dependencies
bundle install

# Initialize MegaBar
bundle exec rake mega_bar:engine_init

echo ""
echo "🎉 SUCCESS! MegaBar application '$APP_NAME' created!"
echo "📁 Navigate to: cd $APP_NAME"
echo "🚀 Start server: rails server"
echo "🌐 Visit: http://localhost:3000" 