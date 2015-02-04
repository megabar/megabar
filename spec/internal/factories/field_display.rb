# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :field_display, class: MegaBar::FieldDisplay do
    model_display_id 1
    field_id 1
    format 'textread'
    header 'Hi there, I am a field display'
  end
end
