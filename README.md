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

Add MegaBar to your Gemfile so that it uses your local copy of the gem:

```gem 'mega_bar', :path => '../megabar/' ```

(if you will not be contributing to the gem, you can omit the 'path' segment.)

Bundle Install

```bundle install```

Mount the mega_bar engine into your routes file:

```bundle exec rake mega_bar:engine_init```

Migrate the db:

```rake db:migrate```

Copy the 'core data' seeds over from the gem to your repo:

```cp ../megabar/db/mega_bar.seeds.rb db/.```

Load the seeds:

```bundle exec rake mega_bar:data_load```

Start your server

```rails s```

Visit a megabar page at http://localhost:3000/mega-bar/models

If you have additions to the 'core data' and would like them to be a part of the 'mega_bar seeds', run this command:

```bundle exec rake  mega_bar:dump_seeds```

Then you'd copy that db/mega_bar.seeds.rb from your app over to the megabar repo and commit them to the megabar repo. 

```cp db/mega_bar.seeds.rb ../megabar/db/.```

Some file changes that become a part of your app will also have to be copied over to the megabar repo if you want them to become a permanent part of megabar. If you really want to create a new core model, you'll need to create it and a mirror 'tmp' version of the model files and copy those and the migrations back over to the gem as well. Ask.

Definitely consider creating a branch before making changes to the megabar gem repo and then submit a pull request.

```git checkout -b feature/my_new_feature```

build feature

```git commit -am "built a feature ```

```git push --set-upstream origin feature/myfeature```

Then go to the github page and submit a pull request from there.


