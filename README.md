megabar
=======

MegaBar is a enterprise scale website and api building tool. 

## 🚀 Revolutionary Deterministic IDs System

MegaBar now features a revolutionary deterministic ID system that eliminates seed conflicts entirely! The same logical record always gets the same ID across all applications, making seed loading fast, reliable, and conflict-free.

### Key Benefits:
- **Zero conflicts** - deterministic IDs eliminate conflicts entirely
- **80-90% faster** - no tmp table overhead
- **Idempotent** - safe to run multiple times
- **Simplified** - no complex conflict resolution needed

Installation

Go to a directory where you have other rails apps.. perhaps ~/websites/ if you want to start a new one.

```cd ~/websites```

Clone (or fork) this repo

```git clone https://github.com/megabar/megabar.git```

Create a new app (you can also just add the gem to an existing app)

```rails new myapp ```

```cd myapp```

Add all of this to your gemfile: 
```
gem 'mega_bar', :path => '../megabar/'
group :development, :test do
  gem 'byebug'
  gem 'rspec-rails', '~> 3.0'
  gem 'factory_girl_rails', require: false
end
gem 'best_in_place'
gem 'jquery-ui-rails'
gem 'kaminari', '~> 0.17.0'
gem 'bootstrap-sass', '3.2.0.2'

```
Also, remove Spring as a gem from your Gemfile. 

After you've edited your Gemfile, I have a one line shortcut command for all those things once you've edited your Gemfile:

```rbenv local 2.3.0; bundle install; rails generate rspec:install; cp ../megabar/spec/host_spec_helper.rb spec/spec_helper.rb; bundle exec rake mega_bar:engine_init; rails s;```

You should then be able to visit a megabar page at http://localhost:3000/mega-bar/models

If you are adding megabar to an existing application, you might want to run each of those commands separately and you'd probably want to carefully merge the contents of the host_spec_helper.rb into your existing spec_helper. Also, you may not need the rbenv command or want to use an rvm version.

## 🚀 Revolutionary Seed System

### Getting Latest Seeds (New Deterministic System)

Getting the latest from the MegaBar Team for your existing megabar app is now super fast and conflict-free:

```
megabar directory: > git pull
myapp directory: > rake db:migrate
myapp directory: > bundle exec rake mega_bar:load_deterministic_seeds
```

The new deterministic system:
- Loads directly into permanent tables (no tmp tables!)
- Uses `find_or_create_by` for idempotent operations
- Generates deterministic IDs based on record content
- Completes in ~6 seconds (vs 30+ seconds with old system)

### Creating New Seeds (New Deterministic System)

If you have additions to the 'core data' and would like them to be a part of the 'mega_bar seeds', follow these steps:

#### 1. Dump Seeds from Your Application

```bundle exec rake mega_bar:dump_deterministic_seeds```

This creates `db/mega_bar_deterministic.seeds.rb` with the revolutionary new format that:
- Uses `find_or_create_by` patterns for conflict-free loading
- Includes deterministic ID generation
- Eliminates all tmp table complexity

#### 2. Copy Seeds to MegaBar Repository

Copy the generated seeds file to the megabar repository:

```bash
# From your application directory
cp db/mega_bar_deterministic.seeds.rb ../megabar/db/

# Or with full paths if needed
cp db/mega_bar_deterministic.seeds.rb /path/to/megabar/db/
```

#### 3. Commit to MegaBar Repository

Navigate to the megabar repository and commit the new seeds:

```bash
cd ../megabar
git add db/mega_bar_deterministic.seeds.rb
git commit -m "🌱 Update deterministic seeds with new core data

- Added new [describe your changes]
- Generated from [your app name] 
- Uses deterministic IDs for conflict-free loading
- Ready for distribution to all applications"
```

#### 4. Push and Create Pull Request

```bash
git push origin your-branch-name
```

Then create a pull request on GitHub to merge your seeds into the main megabar repository.

#### 5. Distribute to Other Applications

Once merged, other applications can get the latest seeds:

```bash
# In any megabar application
cd ../megabar && git pull
cd ../your-app
bundle exec rake mega_bar:load_deterministic_seeds
```

### Important Notes

- **Always test** your dumped seeds in a fresh application before committing
- **Document changes** in your commit message for team awareness  
- **Coordinate with team** when making significant seed changes
- **Use branches** for seed updates to allow review before merging

### Legacy System (Deprecated)

The old tmp table system is still available but deprecated:
```
# Legacy commands (slower, conflict-prone)
bundle exec rake mega_bar:data_load        # Old loading system
bundle exec rake mega_bar:dump_seeds       # Old dumping system
```

**Recommendation**: Use the new deterministic system for all new development!

## Development Workflow

Also copy any related migrations. Adding new models to core megabar involves adding them to the deterministic seed tasks. 

Definitely consider creating a branch before making changes to the megabar gem repo and then submit a pull request.

```git checkout -b feature/my_new_feature```

build feature.....

```git commit -am "built a feature"```

```git push --set-upstream origin feature/myfeature```

Then go to the github page and submit a pull request from there.

## Deterministic ID Ranges

The new system uses specific ID ranges for each model type:

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
- **UI Components**: 15000-19999
- **Join Tables**: 20000-22999
- **Additional Models**: 23000+

This ensures no ID conflicts between different model types and provides room for growth. 