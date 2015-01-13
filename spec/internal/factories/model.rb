# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :model, class: MegaBar::Model do
    classname 'beep'
    schema  'deep'
    tablename 'meep'
    name 'zeep'
    default_sort_field 'tweep'  
  end
end
