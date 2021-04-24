
require 'byebug'

load File.expand_path("../../../../lib/tasks/mega_bar_tasks.rake", __FILE__)
Rake::Task.define_task(:environment)
Rake::Task['mega_bar:data_load'].invoke('../../db/mega_bar.seeds.rb', 'routes')

Rails.application.routes.draw do
  mount MegaBar::Engine, at: '/mega-bar'
end
