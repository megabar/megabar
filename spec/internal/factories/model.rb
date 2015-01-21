# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :model, class: MegaBar::Model do
    classname 'beep'
    schema  'deep'
    tablename 'meeps'
    name 'zeep'
    default_sort_field 'id'  
    factory :model_with_everything do
      after(:create) do |model|
       create(:model_display, model: model)
      end
    end
  end
end
