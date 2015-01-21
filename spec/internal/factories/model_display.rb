# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :model_display, class: MegaBar::ModelDisplay do
    model 
    action 'index'
    header 'Hi there, I am a model display'
    format 1
  end
end
