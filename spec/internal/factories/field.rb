# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :field, class: MegaBar::Field do
    model_id  '1'
    schema 'beep'
    tablename 'mega_bar_models'
    field 'steep'
    association :model,  factory: :model
  end
end
