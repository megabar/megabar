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
gem 'kaminari', '~> 0.17.0'

```
Also, remove Spring as a gem from your Gemfile. 

After you've edited your Gemfile, I have a one line shortcut command for all those things once you've edited your Gemfile:

```rbenv local 2.3.0; bundle install; rails generate rspec:install; cp ../megabar/spec/host_spec_helper.rb spec/spec_helper.rb; bundle exec rake mega_bar:engine_init; rails s;```

You should then be able to visit a megabar page at http://localhost:3000/mega-bar/models

Getting the latest from the MegaBar Team takes a few steps.

```megabar directory: > git pull
   myapp directory: > rake db:migrate
   myapp directory: > bundle exec rake  mega_bar:data_load

```


If you have additions to the 'core data' and would like them to be a part of the 'mega_bar seeds', run this command:

```bundle exec rake  mega_bar:dump_seeds```

Then you'd copy that db/mega_bar.seeds.rb from your app over to the megabar repo and commit them to the megabar repo. 
```cp db/mega_bar.seeds.rb ../megabar/db/.```

Also copy any related migrations. 

Definitely consider creating a branch before making changes to the megabar gem repo and then submit a pull request.

```git checkout -b feature/my_new_feature```

build feature.....

```git commit -am "built a feature ```

```git push --set-upstream origin feature/myfeature```

Then go to the github page and submit a pull request from there.


