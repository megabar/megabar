# megabar

MegaBar is an enterprise-scale website and API building tool that provides dynamic form generation, layout management, and data display capabilities.

## MegaBar + CCCUX Authorization Setup

For applications requiring role-based authorization, you can integrate MegaBar with CCCUX:

**Prerequisites**: Both `megabar` and `cccux` repositories must be checked out to the same directory.

```bash
# 0. Clone both repositories side by side
git clone https://github.com/megabar/megabar.git
git clone https://github.com/bagus1/cccux.git

# 1. Create a new MegaBar app
./megabar/create_megabar_app.sh myapp

# 2. Install Devise authentication
bundle add devise && rails generate devise:install && rails generate devise User && rails db:migrate

# 3. Add CCCUX authorization (automatically starts server)
../cccux/add_cccux.sh
```

This will:

- Add CCCUX gem to your Gemfile
- Set up role-based authorization with CanCanCan
- Create admin user and Mega Role
- Initialize MegaBar with authorization
- Start the Rails server automatically

Visit:

- **MegaBar**: http://localhost:3000/mega-bar
- **CCCUX**: http://localhost:3000/cccux

## Installation

Go to a directory where you have other rails apps (perhaps ~/websites/ if you want to start a new one).

`cd ~/websites`

Clone (or fork) this repo

`git clone https://github.com/megabar/megabar.git`

Create a new app (you can also just add the gem to an existing app)

`rails new myapp`

`cd myapp`

Add MegaBar to your Gemfile so that it uses your local copy of the gem:

```ruby
gem 'mega_bar', :path => '../megabar/'

group :development, :test do
  gem 'byebug'
  gem 'rspec-rails', '~> 3.0'
  gem 'factory_girl_rails', require: false
end

gem 'best_in_place'
gem 'jquery-ui-rails'
```

(If you will not be contributing to the gem, you can omit the 'path' segment.)

Bundle Install

`bundle install`

Generate Rspec Directory:

`rails generate rspec:install`

Overwrite the existing spec_helper

`cp ../megabar/spec/host_spec_helper.rb spec/spec_helper.rb`

Run the init task:

`bundle exec rake mega_bar:engine_init`

If this step gives you any trouble, feel free to drop me a line.

Start your server

`rails s`

Visit a megabar page at http://localhost:3000/mega-bar/models

## Quick Start: Automated App Creation

### Option 1: Rails Application Template

Create a complete MegaBar application with a single command:

```bash
rails new myapp -m megabar_app_template.rb --skip-git
```

This automatically:

- Creates a new Rails application
- Adds MegaBar gem with all dependencies
- Runs `bundle install`
- Executes `mega_bar:engine_init` with deterministic seeds
- Completes setup in ~30 seconds

### Option 2: Shell Script

Alternative automation using the provided shell script:

```bash
./create_megabar_app.sh myapp
```

## Features

- **Dynamic Model Generation**: Create models, controllers, and migrations through the web interface
- **Form Builder**: Automatic form generation with various field types
- **Layout Management**: Drag-and-drop page and block layout system
- **Data Display**: Configurable index, show, and edit views
- **Deterministic IDs**: Consistent ID generation across environments for reliable seeding
- **RSpec Integration**: Automatic test setup for generated models
- **Authorization Integration**: Works with CCCUX for role-based permissions

## Seed Management

### Getting Latest Seeds

To get the latest seeds from the MegaBar team:

```bash
# In megabar directory
git pull

# In your app directory
rake db:migrate
bundle exec rake mega_bar:load_deterministic_seeds
```

### Creating New Seeds

If you have additions to the 'core data' and would like them to be part of the 'mega_bar seeds':

1. **Dump Seeds from Your Application**

`bundle exec rake mega_bar:dump_deterministic_seeds`

This creates `db/mega_bar_deterministic.seeds.rb` with deterministic ID generation.

2. **Copy Seeds to MegaBar Repository**

```bash
# From your application directory
cp db/mega_bar_deterministic.seeds.rb ../megabar/db/
```

3. **Commit to MegaBar Repository**

```bash
cd ../megabar
git add db/mega_bar_deterministic.seeds.rb
git commit -m "Update deterministic seeds with new core data"
git push origin your-branch-name
```

4. **Create Pull Request**

Submit a pull request on GitHub to merge your seeds into the main megabar repository.

### Important Notes

- **Always test** your dumped seeds in a fresh application before committing
- **Document changes** in your commit message for team awareness
- **Coordinate with team** when making significant seed changes
- **Use branches** for seed updates to allow review before merging

## Development Workflow

MegaBar will generate model, controller and migration files for you. It will also set your new models up to be tested with rspec.

If you have additions to the 'core data' and would like them to be a part of the 'mega_bar seeds', run this command:

`bundle exec rake mega_bar:dump_seeds`

Then you'd copy that `db/mega_bar.seeds.rb` from your app over to the megabar repo and commit them to the megabar repo.

`cp db/mega_bar.seeds.rb ../megabar/db/.`

Some file changes that become a part of your app will also have to be copied over to the megabar repo if you want them to become a permanent part of megabar. If you really want to create a new core model, you'll need to create it and a mirror 'tmp' version of the model files and copy those and the migrations back over to the gem as well. Ask.

Definitely consider creating a branch before making changes to the megabar gem repo and then submit a pull request.

`git checkout -b feature/my_new_feature`

build feature.....

`git commit -am "built a feature"`

`git push --set-upstream origin feature/myfeature`

Then go to the github page and submit a pull request from there.

## Deterministic ID System

MegaBar uses a deterministic ID system that ensures the same logical record always gets the same ID across all applications. This eliminates seed conflicts and makes seed loading faster and more reliable.

### ID Ranges

The system uses specific ID ranges for each model type:

- **Fields**: 1000-1999
- **ModelDisplays**: 2000-2999
- **FieldDisplays**: 3000-3999
- **Pages**: 4000-4999
- **Layouts**: 5000-5999
- **LayoutSections**: 6000-6999
- **Blocks**: 7000-7999
- **Options**: 8000-8999
- **Models**: 9000-9999
- **Sites**: 10000-10999
- **Themes**: 11000-11999
- **Templates**: 12000-12999
- **TemplateSections**: 13000-13999
- **Portfolios**: 14000-14999
- **UI Components**: 15000-28999
- **Join Tables**: 20000-22999
- **Additional Models**: 29000+

This ensures no ID conflicts between different model types and provides room for growth.

## Legacy System

The old tmp table system is still available but deprecated:

```bash
# Legacy commands (slower, conflict-prone)
bundle exec rake mega_bar:data_load        # Old loading system
bundle exec rake mega_bar:dump_seeds       # Old dumping system
```

**Recommendation**: Use the new deterministic system for all new development!
