megabar
=======

MegaBar is a enterprise scale website and api building tool. 

Installation

Go to a directory where you have other rails apps.. perhaps ~/websites/ if you want to start a new one.

```cd ~/websites```

Clone (or fork) this repo

```git clone https://github.com/megabar/megabar.git```

Create a new app (you can also just add the gem to an existing app)

```rails new myapp ```

```cd myapp```

Aadd all of this to your gemfile: 
```
gem 'mega_bar', :path => '../megabar/'

group :development, :test do
  gem 'byebug'
  gem 'rspec-rails', '~> 3.0'
  gem 'factory_girl_rails', require: false
end

gem 'best_in_place'

gem 'jquery-ui-rails'
```
Also, remove Spring as a gem from your Gemfile. 

Then continue from the command line.
Bundle Install

```bundle install```

Generate Rspec Directory: 

```rails generate rspec:install```

Overwrite the existing spec_helper

```cp ../megabar/spec/host_spec_helper.rb spec/spec_helper.rb``` 

Run the init task:

```bundle exec rake mega_bar:engine_init```

If this step gives you any trouble, feel free to drop me a line.

Start your server

```rails s```

Visit a megabar page at http://localhost:3000/mega-bar/models

I have a one line shortcut command for all those things once you've edited your Gemfile:

```rbenv local 2.3.0; bundle install; rails generate rspec:install; cp ../megabar/spec/host_spec_helper.rb spec/spec_helper.rb; bundle exec rake mega_bar:engine_init; rails s;```


If you have additions to the 'core data' and would like them to be a part of the 'mega_bar seeds', run this command:

```bundle exec rake  mega_bar:dump_seeds```

Then you'd copy that db/mega_bar.seeds.rb from your app over to the megabar repo and commit them to the megabar repo. 
```cp db/mega_bar.seeds.rb ../megabar/db/.```

If you have an existing myapp and want to bring in seeds from megabar master, after you git pull in megabar directory, go to your myapp directory and enter

```bundle exec rake  mega_bar:data_load```

Some file changes that become a part of your app will also have to be copied over to the megabar repo if you want them to become a permanent part of megabar. If you really want to create a new core model, you'll need to create it and a mirror 'tmp' version of the model files and copy those and the migrations back over to the gem as well. Ask.

Definitely consider creating a branch before making changes to the megabar gem repo and then submit a pull request.

```git checkout -b feature/my_new_feature```

build feature

```git commit -am "built a feature ```

```git push --set-upstream origin feature/myfeature```

Then go to the github page and submit a pull request from there.


