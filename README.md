megabar
=======

Go to a directory where you have other rails apps.. perhaps ~/websites/ if you want to start a new one.
```cd ~/websites```

Clone (or fork) this repo
```git clone https://github.com/megabar/megabar.git```

Create a new app (you can also just add the gem to an existing app)
```rails new myapp ```
```cd myapp```

Add MegaBar to your Gemfile so that it uses your local copy of the gem:
```gem 'mega_bar', :path => '../MegaBar/' ```

(if you will not be contributing to the gem, you can omit the 'path' segment.)

Bundle Install
```bundle install```
