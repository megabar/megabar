# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :field_display, class: MegaBar::FieldDisplay do
    field_id 2
    format 'textread'
    action 'index'
    header 'Hi there, I am a field display'
  end
end
